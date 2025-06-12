from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.config import get_db
from src.users.exceptions import UserNotFoundException
from src.users.schemas import UserResponse
from src.users.service import UserService

user_router = APIRouter(prefix="/users", tags=["users"])


@user_router.get("/{user_id}")
async def get_user(
    user_id: UUID, db: AsyncSession = Depends(get_db)
) -> UserResponse:
    user_service = UserService(db)
    try:
        user = await user_service.get_user_by_id(user_id)
    except UserNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))

    return user
