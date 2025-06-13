from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from contextlib import asynccontextmanager

from .config import settings
from .supabase import supabase
from .logging_config import setup_logging, get_logger
from .middleware import logging_middleware, RequestTrackingMiddleware
from .core.error_handlers import setup_error_handlers
from .core.response import ResponseSerializer


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Initialize logging and other services
    setup_logging()
    logger = get_logger(__name__)
    logger.info("Starting Nuge API server", extra={"event_type": "startup"})
    
    yield
    
    # Shutdown: Cleanup and log shutdown
    logger.info("Shutting down Nuge API server", extra={"event_type": "shutdown"})


app = FastAPI(
    title="Nuge API",
    description="FastAPI backend for Nuge App",
    version="0.1.0",
    lifespan=lifespan,
    debug=settings.API_DEBUG,
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add request tracking middleware
app.add_middleware(RequestTrackingMiddleware)

# Add logging middleware
app.middleware("http")(logging_middleware)

# Setup error handlers
setup_error_handlers(app)

# Import and include routers
from .auth.router import router as auth_router
from .users.router import router as users_router

app.include_router(auth_router, prefix="/auth", tags=["auth"])
app.include_router(users_router, prefix="/users", tags=["users"])


@app.get("/")
async def root():
    """Root endpoint providing API information."""
    return ResponseSerializer.success(
        data={"message": "Welcome to Nuge API. Check /docs for API documentation."},
        message="API information retrieved successfully"
    )


@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring."""
    return ResponseSerializer.success(
        data={"status": "healthy", "version": "0.1.0"},
        message="Service is healthy"
    )


if __name__ == "__main__":
    uvicorn.run(
        "src.main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.API_DEBUG,
    )