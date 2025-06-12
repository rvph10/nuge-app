from logging.config import fileConfig

from sqlalchemy import create_engine

from alembic import context
from src.config import settings
from src.db.config import Base
from src.db.utils import encode_db_str
from src.payments.models import Payment

config = context.config

fileConfig(config.config_file_name)

target_metadata = Base.metadata

sync_database_url = encode_db_str(
    settings.supabase_db_conn_str,
    is_async=False,
)


def run_migrations_online():
    """Run migrations in 'online' mode."""
    connectable = create_engine(sync_database_url)

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
        )

        with connection.begin():
            context.run_migrations()


# Entry point for migrations
if context.is_offline_mode():
    context.configure(url=sync_database_url, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()
else:
    run_migrations_online()
