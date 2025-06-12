# Setup and Installation

## Prerequisites

Before you begin, ensure that you have the following installed on your system:

1. **Python 3.8+**: Install Python from [python.org](https://www.python.org/).
2. **Docker (optional)**: For containerized deployment.

## Setup & Installation

### Step 1: Clone the Repository

```bash
# Replace <repository-url> with your repository URL
git clone <repository-url>
cd <repository-directory>
```

### Step 2: Install Dependencies

Use `uv` for package and project management:

To download uv, uv's documentation is available at [docs.astral.sh/uv](https://docs.astral.sh/uv).

Once uv is installed, run (in the project directory):

```bash
uv pip install -r pyproject.toml
```

This will install all required dependencies as specified in the `pyproject.toml`

### Step 3: Configure Environment Variables

```env
# SUPABASE
SUPABASE_URL=
SUPABASE_KEY=
SUPABASE_JWT_SECRET_KEY=
SUPABASE_DB_CONN_STR=

# STRIPE
STRIPE_API_KEY=
STRIPE_WEBHOOK_SECRET=
```

Replace the placeholders with the actual values specific to your project.

Where

### Supabase

- **SUPABASE_URL** is retrieved from `Project Settings > API > Project URL > URL`.
- **SUPABASE_KEY** is retrieved from `Project Settings > API > Project API Keys > anon public`.
- **SUPABASE_JWT_SECRET_KEY** is retrieved from `Project Settings > API > JWT Settings > JWT Secret`.
  **SUPABASE_DB_CONN_STR** is retrieved by:
  - Pressing the connect button next to your project name.
  - **If running your server locally:**
    - Select **Session pooler**.
    - Replace `postgres://` with `postgresql+asyncpg://`.
    - Include your actual password.
  - **Otherwise:**
    - Select **Direct Connection**.
    - Replace `postgres://` with `postgresql+asyncpg://`.
    - Include your actual password.

### Stripe

- **STRIPE_API_KEY** is retrieved from your Stripe Dashboard under `Developers > API Keys`. Use the **Secret Key**.
- **STRIPE_WEBHOOK_SECRET**:
  - **Option 1**: Retrieve it from your Stripe Dashboard under `Developers > Webhooks`. After creating a webhook endpoint, copy the **Signing Secret**.
  - **Option 2**: When running locally, you can retrieve it using the Stripe CLI by running:
    ```bash
    stripe listen --print-secret
    ```
    This will output the webhook secret directly in your terminal.

### Step 4: Run Migrations

Once the database is connected it's time to run the initial database migration to create the Payments table:

```bash
uv run alembic upgrade head
```

### Step 5: Run the Application

#### Without Docker

Run the application locally using `uvicorn`:

```bash
uv run uvicorn src.main:app --reload
```

Alternatively, if you have `make` installed on your machine, you can use the following command:

```bash
make server
```

#### With Docker

1. Build the Docker image:

   ```bash
   docker build -t supafast .
   ```

2. Run the Docker container:

   ```bash
   docker run -d -p 8000:8000 --env-file .env supafast
   ```

---
