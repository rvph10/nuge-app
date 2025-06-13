from typing import Optional

from fastapi import HTTPException, status

from ..supabase import supabase
from .schemas import Token, UserCreate, UserLogin, UserResponse


class AuthService:
    @staticmethod
    async def register(user_data: UserCreate) -> UserResponse:
        """
        Register a new user with Supabase Auth.
        """
        try:
            # Register user with Supabase Auth
            auth_response = supabase.auth.sign_up(
                {
                    "email": user_data.email,
                    "password": user_data.password,
                }
            )

            if not auth_response.user:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Failed to register user",
                )

            # Create user record in the users table
            user_record = {
                "id": auth_response.user.id,
                "email": user_data.email,
                "full_name": user_data.full_name,
            }

            response = supabase.table("users").insert(user_record).execute()

            if not response.data:
                # If user table insert fails, we should handle this (ideally delete the auth user)
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="User created but failed to save user data",
                )

            return UserResponse(**response.data[0])

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Registration failed: {str(e)}",
            )

    @staticmethod
    async def login(credentials: UserLogin) -> Token:
        """
        Authenticate a user and return JWT token.
        """
        try:
            auth_response = supabase.auth.sign_in_with_password(
                {
                    "email": credentials.email,
                    "password": credentials.password,
                }
            )

            if not auth_response.user:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Incorrect email or password",
                )

            # Use the session token from Supabase auth
            access_token = auth_response.session.access_token

            return Token(access_token=access_token)

        except Exception:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authentication failed",
            )

    @staticmethod
    async def get_user_by_id(user_id: str) -> Optional[UserResponse]:
        """
        Get user details by ID.
        """
        response = supabase.table("users").select("*").eq("id", user_id).execute()

        if not response.data:
            return None

        return UserResponse(**response.data[0])
