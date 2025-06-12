# Use a lightweight Python image
FROM python:3.10-slim

WORKDIR /app

# Install psycopg2 system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY . .

# Install dependencies
RUN pip install uv && uv venv && uv pip install -r pyproject.toml


EXPOSE 8000

CMD ["uv", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]