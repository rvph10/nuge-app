from typing import Any, Dict, List, Optional, TypeVar, Generic, Type
from pydantic import BaseModel

T = TypeVar('T', bound=BaseModel)


class DBUtils(Generic[T]):
    """
    Utility class for database operations using Supabase.
    """
    def __init__(self, table_name: str, model_class: Type[T]):
        self.table_name = table_name
        self.model_class = model_class
        
    async def get_by_id(self, client, id: str) -> Optional[T]:
        """Get a record by its ID."""
        response = client.table(self.table_name).select("*").eq("id", id).execute()
        data = response.data
        if not data:
            return None
        return self.model_class(**data[0])
    
    async def get_all(self, client, limit: int = 100, offset: int = 0) -> List[T]:
        """Get all records with pagination."""
        response = client.table(self.table_name).select("*").range(offset, offset + limit - 1).execute()
        return [self.model_class(**item) for item in response.data]
    
    async def create(self, client, data: Dict[str, Any]) -> T:
        """Create a new record."""
        response = client.table(self.table_name).insert(data).execute()
        return self.model_class(**response.data[0])
    
    async def update(self, client, id: str, data: Dict[str, Any]) -> Optional[T]:
        """Update a record by its ID."""
        response = client.table(self.table_name).update(data).eq("id", id).execute()
        if not response.data:
            return None
        return self.model_class(**response.data[0])
    
    async def delete(self, client, id: str) -> bool:
        """Delete a record by its ID."""
        response = client.table(self.table_name).delete().eq("id", id).execute()
        return len(response.data) > 0