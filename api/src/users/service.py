from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from src.users.exceptions import UserNotFoundException
from src.users.models import User
from src.users.schemas import UserResponse


class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_user_by_id(self, user_id: UUID) -> UserResponse:
        query = select(User).where(User.id == user_id)
        result = await self.db.execute(query)
        user = result.scalar_one_or_none()

        if not user:
            raise UserNotFoundException(f"User with ID {user_id} not found")

        return UserResponse.model_validate(user)
