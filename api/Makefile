.PHONY: help setup run test lint format clean

# Default target
.DEFAULT_GOAL := help

# Python interpreter
PYTHON := python
VENV := venv
PIP := $(VENV)/bin/pip

# Application settings
APP_MODULE := src.main:app
HOST := 0.0.0.0
PORT := 8080

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Set up virtual environment and install dependencies
	$(PYTHON) -m venv $(VENV)
	$(PIP) install -e .
	@echo "Setup complete. Activate the virtual environment with 'source $(VENV)/bin/activate'"

run: ## Run the development server
	$(VENV)/bin/uvicorn $(APP_MODULE) --reload --host $(HOST) --port $(PORT)

test: ## Run tests
	$(VENV)/bin/pytest

lint: ## Run linters
	$(VENV)/bin/ruff src tests
	$(VENV)/bin/black --check src tests

format: ## Format code
	$(VENV)/bin/black src tests
	$(VENV)/bin/ruff --fix src tests

clean: ## Clean up temporary files and build artifacts
	rm -rf __pycache__
	rm -rf src/__pycache__
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf htmlcov
	rm -rf dist
	rm -rf build
	rm -rf *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

env-setup: ## Create .env file from example if it doesn't exist
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created from .env.example. Please update it with your configuration."; \
	else \
		echo ".env file already exists."; \
	fi

install-dev: ## Install development dependencies
	$(PIP) install -e ".[dev]"

serve: ## Run production server
	$(VENV)/bin/uvicorn $(APP_MODULE) --host $(HOST) --port $(PORT)

docs: ## Generate API documentation (requires redoc-cli)
	$(PYTHON) -c "import json; from src.main import app; print(json.dumps(app.openapi()))" > openapi.json
	npx redoc-cli bundle openapi.json -o docs/index.html