from typing import List, Optional

from ..supabase import supabase
from ..db.utils import DBUtils
from .schemas import UserResponse, UserUpdate, UserListResponse


class UserService:
    db_utils = DBUtils("users", UserResponse)
    
    @classmethod
    async def get_users(cls, limit: int = 100, offset: int = 0) -> UserListResponse:
        """
        Get a list of users with pagination.
        """
        response = supabase.table("users").select("*", count="exact").range(offset, offset + limit - 1).execute()
        
        return UserListResponse(
            items=[UserResponse(**item) for item in response.data],
            total=response.count
        )
    
    @classmethod
    async def get_user_by_id(cls, user_id: str) -> Optional[UserResponse]:
        """
        Get a user by ID.
        """
        return await cls.db_utils.get_by_id(supabase, user_id)
    
    @classmethod
    async def update_user(cls, user_id: str, user_data: UserUpdate) -> Optional[UserResponse]:
        """
        Update a user's information.
        """
        update_data = user_data.model_dump(exclude_unset=True)
        if not update_data:
            # No fields to update
            return await cls.get_user_by_id(user_id)
            
        return await cls.db_utils.update(supabase, user_id, update_data)
    
    @classmethod
    async def delete_user(cls, user_id: str) -> bool:
        """
        Delete a user.
        """
        return await cls.db_utils.delete(supabase, user_id)