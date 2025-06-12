# supafast Folder Structure

This document outlines the folder structure of the supafast project to help developers navigate the codebase efficiently.

```
supafast/
├── alembic/                # Database migrations using Alembic
├── scripts/                # Utility scripts for creating new modules (beta)
├── src/
│   ├── auth/               # Authentication module
│   │   ├── __init__.py
│   │   ├── dependency.py   # Dependency injection callables
│   │   ├── enum.py         # Enums for auth
│   │   ├── router.py       # API routes for authentication
│   │   ├── schemas.py      # Pydantic schemas for authentication
│   │   ├── service.py      # Authentication service logic
│   ├── db/                 # Database configuration and utilities
│   │   ├── __init__.py
│   │   ├── config.py       # Database configuration
│   │   ├── utils.py        # Database utility functions
│   ├── payments/           # Payments module
│   │   ├── __init__.py
│   │   ├── configs.py      # Configuration for payments (env vars)
│   │   ├── exceptions.py   # Custom exceptions for payments
│   │   ├── models.py       # ORM models for payments
│   │   ├── router.py       # API routes for payments
│   │   ├── schemas.py      # Pydantic schemas for payments
│   │   ├── service.py      # Payments service logic
│   │   ├── webhook_service.py # Webhook handling for payments
│   │   ├── webhook_utils.py   # Utilities for payment webhooks
│   ├── users/              # Users module
│   │   ├── __init__.py
│   │   ├── exceptions.py   # Custom exceptions for users
│   │   ├── models.py       # ORM models for users
│   │   ├── router.py       # API routes for users
│   │   ├── schemas.py      # Pydantic schemas for users
│   │   ├── service.py      # Users service logic
│   ├── main.py             # Entry point for the FastAPI application
|   ├── supabase.py         # Supabase client
|   ├── config.py           # Root Configuration (env vars)
├── .env                    # Environment variables (needs to be added)
├── .env.example            # Example environment variables
├── .gitignore              # Git ignore file
├── .python-version         # Python version used
```

## Notes

- **`src/`**: Contains all source code organized by feature (auth, payments, users).
- **`auth/`**: Handles authentication logic, including routes, dependencies, and services.
- **`db/`**: Centralized database configuration and utility functions.
- **`payments/`**: Manages payment processing, models, webhooks, and related functionality.
- **`users/`**: Manages user-related functionality, including models, routes, and services.
- **`alembic/`**: Manages database migrations.
- **`docs/`**: Contains project documentation.
- **`scripts/`**: Stores scripts for automating creation of a new module (Beta).
- **`Dockerfile`**: Define containerization setup.

This structure ensures modularity, maintainability, and scalability of the supafast project.
