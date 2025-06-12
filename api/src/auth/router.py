from fastapi import APIRouter

from src.auth.schemas import LoginRequest, SignUpRequest
from src.auth.service import AuthService

auth_router = APIRouter(prefix="/auth", tags=["auth"])
auth_service = AuthService()


@auth_router.post("/signup", status_code=200)
async def signup(signup_request: SignUpRequest):
    return await auth_service.signup(signup_request=signup_request)


@auth_router.post("/login", status_code=200)
async def login(login_request: LoginRequest):
    return await auth_service.login(login_request=login_request)
