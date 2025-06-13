# Nuge API

FastAPI backend for the Nuge App. This API provides authentication and user management features, integrating with Supabase for data storage.

## Features

- User authentication (register, login, get current user)
- User management (get user, update user, delete user)
- Supabase integration for database operations
- Environment configuration
- CORS support

## Prerequisites

- Python 3.9+
- Supabase account and project
- Poetry (recommended) or pip for dependency management

## Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd nuge-app
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -e ./api
   ```

4. Set up environment variables:
   ```bash
   cp api/.env.example api/.env
   ```
   Edit the `.env` file with your Supabase credentials.

## Running the API

Start the development server:

```bash
cd api
python -m src.main
```

Or use uvicorn directly:

```bash
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at [http://localhost:8000](http://localhost:8000).

## API Documentation

Interactive API documentation is available at:

- Swagger UI: [http://localhost:8000/docs](http://localhost:8000/docs)
- ReDoc: [http://localhost:8000/redoc](http://localhost:8000/redoc)

## Project Structure

```
api/
├── src/
│   ├── auth/               # Authentication module
│   │   ├── router.py       # Auth routes
│   │   ├── schemas.py      # Auth data models
│   │   ├── service.py      # Auth business logic
│   │   └── dependency.py   # Auth dependencies
│   ├── users/              # Users module
│   │   ├── router.py       # User routes
│   │   ├── schemas.py      # User data models
│   │   └── service.py      # User business logic
│   ├── db/                 # Database utilities
│   │   └── utils.py        # DB helper functions
│   ├── config.py           # Configuration settings
│   ├── supabase.py         # Supabase client
│   └── main.py             # FastAPI application
├── pyproject.toml          # Project dependencies
└── .env.example            # Example environment variables
```

## Development

### Adding New Modules

To add a new feature module:

1. Create a new directory in `src/`
2. Add the necessary files (`router.py`, `schemas.py`, `service.py`)
3. Include the router in `main.py`

### Database Migrations

This project uses Supabase for database operations. Migrations should be managed through the Supabase interface or CLI.

## License

MIT