from urllib.parse import quote


def encode_db_str(raw_str: str, is_async: bool = True) -> str:
    prefix, rest = raw_str.split("://", 1)
    user_info, host_info = rest.rsplit("@", 1)
    username, password = user_info.rsplit(":", 1)

    # Encode the password
    encoded_password = quote(password)
    
    # Use asyncpg driver for async connections, psycopg2 for sync
    if prefix == "postgresql":
        if is_async:
            prefix = "postgresql+asyncpg"
        else:
            prefix = "postgresql+psycopg2"

    return f"{prefix}://{username}:{encoded_password}@{host_info}"
