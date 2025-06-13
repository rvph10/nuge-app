from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from datetime import datetime, timedelta
from typing import Optional

from ..config import settings
from ..supabase import supabase
from .schemas import TokenPayload, UserResponse

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


async def get_current_user(token: str = Depends(oauth2_scheme)) -> UserResponse:
    """
    Dependency to get the current authenticated user from the token.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # Decode JWT token
        payload = jwt.decode(
            token, 
            settings.SUPABASE_JWT_SECRET, 
            algorithms=["HS256"]
        )
        
        # Extract user ID from token
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        
        # Get user from Supabase
        response = supabase.table("users").select("*").eq("id", user_id).execute()
        user_data = response.data
        
        if not user_data:
            raise credentials_exception
            
        return UserResponse(**user_data[0])
        
    except JWTError:
        raise credentials_exception