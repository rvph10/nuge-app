"""
Example refactored users router demonstrating the new response serializers and error handling.

This file shows how to migrate from the old response format to the new
standardized response format using ResponseSerializer and custom exceptions.
"""

from fastapi import APIRouter, Depends, Query, Request
from typing import Optional

from ..auth.dependency import get_current_user
from ..auth.schemas import UserResponse as AuthUserResponse
from ..core import ResponseSerializer, NotFoundError, ForbiddenError
from .schemas import UserResponse, UserUpdate, UserListResponse
from .service import UserService

router = APIRouter()


@router.get("", response_model=None)  # Let ResponseSerializer handle the response model
async def get_users(
    request: Request,
    limit: int = Query(100, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: AuthUserResponse = Depends(get_current_user),
):
    """
    Get a list of users with pagination.
    
    Returns a standardized paginated response with user data.
    """
    users_data = await UserService.get_users(limit=limit, offset=offset)
    
    # Calculate pagination values
    page = (offset // limit) + 1
    total_items = users_data.get("total", 0)
    items = users_data.get("items", [])
    
    # Use the paginated response serializer
    return ResponseSerializer.paginated(
        items=items,
        page=page,
        per_page=limit,
        total_items=total_items,
        message="Users retrieved successfully",
        request_id=getattr(request.state, 'request_id', None)
    )


@router.get("/me", response_model=None)
async def get_my_profile(
    request: Request,
    current_user: AuthUserResponse = Depends(get_current_user)
):
    """
    Get the current user's profile.
    
    Returns the authenticated user's profile information.
    """
    return ResponseSerializer.success(
        data=current_user.dict(),
        message="Profile retrieved successfully",
        request_id=getattr(request.state, 'request_id', None)
    )


@router.get("/{user_id}", response_model=None)
async def get_user(
    user_id: str,
    request: Request,
    current_user: AuthUserResponse = Depends(get_current_user),
):
    """
    Get a user by ID.
    
    Raises:
        NotFoundError: If the user doesn't exist
    """
    user = await UserService.get_user_by_id(user_id)
    if not user:
        raise NotFoundError(
            message="User not found",
            resource_type="user",
            resource_id=user_id
        )
    
    return ResponseSerializer.success(
        data=user.dict() if hasattr(user, 'dict') else user,
        message="User retrieved successfully",
        request_id=getattr(request.state, 'request_id', None)
    )


@router.patch("/{user_id}", response_model=None)
async def update_user(
    user_id: str,
    user_data: UserUpdate,
    request: Request,
    current_user: AuthUserResponse = Depends(get_current_user),
):
    """
    Update a user's information.
    Only the user themselves or an admin can update a user's information.
    
    Raises:
        ForbiddenError: If user tries to update another user's profile
        NotFoundError: If the user doesn't exist
    """
    # Check if user is updating their own profile
    if current_user.id != user_id:
        # TODO: Add admin check here when you have roles implemented
        raise ForbiddenError(
            message="You can only update your own profile",
            resource="user",
            action="update"
        )
    
    updated_user = await UserService.update_user(user_id, user_data)
    if not updated_user:
        raise NotFoundError(
            message="User not found",
            resource_type="user", 
            resource_id=user_id
        )
    
    return ResponseSerializer.success(
        data=updated_user.dict() if hasattr(updated_user, 'dict') else updated_user,
        message="User updated successfully",
        request_id=getattr(request.state, 'request_id', None)
    )


@router.delete("/{user_id}", response_model=None)
async def delete_user(
    user_id: str,
    request: Request,
    current_user: AuthUserResponse = Depends(get_current_user),
):
    """
    Delete a user.
    Only the user themselves or an admin can delete a user.
    
    Raises:
        ForbiddenError: If user tries to delete another user's account
        NotFoundError: If the user doesn't exist
    """
    # Check if user is deleting their own account
    if current_user.id != user_id:
        # TODO: Add admin check here when you have roles implemented
        raise ForbiddenError(
            message="You can only delete your own account",
            resource="user",
            action="delete"
        )
    
    success = await UserService.delete_user(user_id)
    if not success:
        raise NotFoundError(
            message="User not found",
            resource_type="user",
            resource_id=user_id
        )
    
    return ResponseSerializer.no_content(
        message="User deleted successfully",
        request_id=getattr(request.state, 'request_id', None)
    )


# Example of creating a user with validation error handling
@router.post("", response_model=None)
async def create_user(
    user_data: UserUpdate,  # In practice, you'd have a UserCreate schema
    request: Request,
    current_user: AuthUserResponse = Depends(get_current_user),
):
    """
    Create a new user.
    
    Example endpoint showing how to handle creation with proper response format.
    """
    # Example business logic
    created_user = await UserService.create_user(user_data)
    
    return ResponseSerializer.created(
        data=created_user.dict() if hasattr(created_user, 'dict') else created_user,
        message="User created successfully",
        request_id=getattr(request.state, 'request_id', None)
    ) 