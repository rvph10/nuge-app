from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class RawUserMetaDataSchema(BaseModel):
    sub: UUID
    email: str
    last_name: str
    first_name: str
    org_role: str
    email_verified: bool
    phone_verified: bool


class UserResponse(BaseModel):
    id: UUID
    email: str
    created_at: datetime
    updated_at: datetime
    raw_user_meta_data: RawUserMetaDataSchema

    model_config = ConfigDict(from_attributes=True)
