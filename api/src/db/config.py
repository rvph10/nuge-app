from uuid import uuid4

from asyncpg import Connection
from sqlalchemy.ext.asyncio import (AsyncEngine, AsyncSession,
                                    create_async_engine)
from sqlalchemy.orm import declarative_base, sessionmaker

from src.config import Settings, settings
from src.db.utils import encode_db_str

Base = declarative_base()


class CustomConnection(Connection):
    def _get_unique_id(self, prefix: str) -> str:
        return f"__asyncpg_{prefix}_{uuid4()}__"


class DatabaseManager:
    def __init__(self, settings: Settings):
        self.database_url = encode_db_str(settings.supabase_db_conn_str)
        self.engine: AsyncEngine = create_async_engine(
            self.database_url,
            connect_args={
                "statement_cache_size": 0,
                "prepared_statement_cache_size": 0,
                "connection_class": CustomConnection,
            },
        )
        """ Suppressing type check here since mypy and SQLAlchemy
         don't recognize AsyncSession as an alternative to Session"""
        self.async_session_factory = sessionmaker(  # type: ignore
            bind=self.engine,
            class_=AsyncSession,
            expire_on_commit=False,
        )

    async def get_db(self):
        async with self.async_session_factory() as session:
            yield session


db_manager = DatabaseManager(settings)


# Wrapper function to become a consumable dependency
async def get_db():
    async for session in db_manager.get_db():
        yield session
