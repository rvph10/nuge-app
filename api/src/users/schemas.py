from typing import List, Optional

from pydantic import BaseModel, EmailStr, Field


class UserBase(BaseModel):
    email: EmailStr
    full_name: str = Field(..., min_length=2)


class UserUpdate(BaseModel):
    full_name: Optional[str] = Field(None, min_length=2)


class UserResponse(UserBase):
    id: str


class UserListResponse(BaseModel):
    items: List[UserResponse]
    total: int
