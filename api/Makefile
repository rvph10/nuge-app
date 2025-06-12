UVICORN_CMD=uv run uvicorn src.main:app --reload

.PHONY: server
.PHONY: lint

server:
	$(UVICORN_CMD)

lint:
	uv run mypy .
	uv run black src
	uv run isort src
	uv run flake8 src