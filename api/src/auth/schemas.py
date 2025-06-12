from pydantic import BaseModel

from src.auth.enum import Role


class SignUpRequest(BaseModel):
    email: str
    first_name: str
    last_name: str
    password: str
    org_role: Role


class LoginRequest(BaseModel):
    email: str
    password: str
