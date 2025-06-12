import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer
from fastapi.security.http import HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from src.auth.enum import Role
from src.config import settings
from src.db.config import get_db
from src.users.models import User


async def verify_token(token: str, session: AsyncSession = Depends(get_db)):
    try:
        payload = jwt.decode(
            token,
            settings.supabase_jwt_secret_key,
            algorithms=["HS256"],
            audience="authenticated",
        )
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=401, detail="User ID not found in token"
            )

        result = await session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=404, detail="User not found in database"
            )

        payload["org_role"] = user.raw_user_meta_data["org_role"]

        return payload

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


async def get_current_user(
    token: HTTPAuthorizationCredentials = Depends(HTTPBearer()),
    session: AsyncSession = Depends(get_db),
):
    user_data = await verify_token(token=token.credentials, session=session)

    if not user_data:
        raise HTTPException(status_code=401, detail="Unauthorized")

    return user_data


def UsersAllowed(
    allowed_roles: list[Role],
):
    async def dependency(user_data=Depends(get_current_user)):

        user_role = user_data["user_metadata"]["org_role"]
        if not user_role or user_role not in [
            role.value for role in allowed_roles
        ]:
            raise HTTPException(
                status_code=403, detail="Forbidden: Insufficient permissions"
            )
        return user_data

    return dependency
