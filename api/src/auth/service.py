from fastapi import HTTPException

from src.auth.schemas import LoginRequest, SignUpRequest
from src.supabase import create_supabase


class AuthService:
    async def signup(
        self,
        signup_request: SignUpRequest,
    ):
        supabase = await create_supabase()

        try:
            await supabase.auth.sign_up(
                dict(
                    email=signup_request.email,
                    password=signup_request.password,
                    options=dict(
                        data=dict(
                            first_name=signup_request.first_name,
                            last_name=signup_request.last_name,
                            org_role=signup_request.org_role.value,
                        ),
                    ),
                )
            )
            return dict(
                message="User successfully registered.",
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    async def login(self, login_request: LoginRequest):
        supabase = await create_supabase()

        try:
            response = await supabase.auth.sign_in_with_password(
                dict(
                    email=login_request.email,
                    password=login_request.password,
                )
            )
            session = response.session
            return dict(
                message="Login successful",
                access_token=session.access_token,
                refresh_token=session.refresh_token,
            )
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))
