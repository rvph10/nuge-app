from fastapi import APIRouter, Depends, HTTPException, status

from .schemas import UserCreate, UserLogin, Token, UserResponse
from .service import AuthService
from .dependency import get_current_user

router = APIRouter()


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate):
    """
    Register a new user.
    """
    return await AuthService.register(user_data)


@router.post("/login", response_model=Token)
async def login(credentials: UserLogin):
    """
    Authenticate and get access token.
    """
    return await AuthService.login(credentials)


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: UserResponse = Depends(get_current_user)):
    """
    Get information about the currently authenticated user.
    """
    return current_user