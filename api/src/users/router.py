from fastapi import APIRouter, Depends, HTTPException, Query, status

from ..auth.dependency import get_current_user
from ..auth.schemas import UserResponse as AuthUserResponse
from .schemas import UserListResponse, UserResponse, UserUpdate
from .service import UserService

router = APIRouter()


@router.get("", response_model=UserListResponse)
async def get_users(
    limit: int = Query(100, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: AuthUserResponse = Depends(get_current_user),
):
    """
    Get a list of users with pagination.
    """
    return await UserService.get_users(limit=limit, offset=offset)


@router.get("/me", response_model=UserResponse)
async def get_my_profile(current_user: AuthUserResponse = Depends(get_current_user)):
    """
    Get the current user's profile.
    """
    return current_user


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    current_user: AuthUserResponse = Depends(get_current_user),
):
    """
    Get a user by ID.
    """
    user = await UserService.get_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return user


@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: str,
    user_data: UserUpdate,
    current_user: AuthUserResponse = Depends(get_current_user),
):
    """
    Update a user's information.
    Only the user themselves or an admin can update a user's information.
    """
    # Check if user is updating their own profile
    if current_user.id != user_id:
        # TODO: Add admin check here when you have roles implemented
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only update your own profile",
        )

    updated_user = await UserService.update_user(user_id, user_data)
    if not updated_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return updated_user


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: str,
    current_user: AuthUserResponse = Depends(get_current_user),
):
    """
    Delete a user.
    Only the user themselves or an admin can delete a user.
    """
    # Check if user is deleting their own account
    if current_user.id != user_id:
        # TODO: Add admin check here when you have roles implemented
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only delete your own account",
        )

    success = await UserService.delete_user(user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
