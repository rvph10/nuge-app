from sqlalchemy import Column, DateTime, String
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import DeclarativeBase


class AuthBase(DeclarativeBase):
    pass


class User(AuthBase):
    __tablename__ = "users"  # The table name
    __table_args__ = {"schema": "auth"}

    id = Column(UUID(as_uuid=True), primary_key=True)
    email = Column(String, unique=True, nullable=False)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
    raw_user_meta_data = Column(JSONB, nullable=True)
