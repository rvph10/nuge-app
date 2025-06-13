"""
Error handlers and middleware for the Nuge API.

This module provides centralized error handling for all exceptions,
converting them to standardized response formats.
"""

import traceback
import uuid
from typing import Union, Dict, Any
from fastapi import Request, HTTPException, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from pydantic import ValidationError as PydanticValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

from .exceptions import NugeException
from .response import ResponseSerializer, ErrorDetail
from ..logging_config import get_logger

logger = get_logger(__name__)


async def nuge_exception_handler(request: Request, exc: NugeException) -> JSONResponse:
    """
    Handle custom Nuge exceptions.
    
    Args:
        request: The FastAPI request object
        exc: The custom exception instance
        
    Returns:
        JSONResponse with standardized error format
    """
    request_id = getattr(request.state, 'request_id', str(uuid.uuid4()))
    
    # Log the error
    logger.error(
        f"Nuge exception: {exc.message}",
        extra={
            "error_code": exc.error_code,
            "status_code": exc.status_code,
            "details": exc.details,
            "request_id": request_id,
            "path": request.url.path,
            "method": request.method
        }
    )
    
    return ResponseSerializer.error(
        message=exc.message,
        error_code=exc.error_code,
        status_code=exc.status_code,
        details=exc.details,
        request_id=request_id
    )


async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """
    Handle FastAPI HTTPException.
    
    Args:
        request: The FastAPI request object
        exc: The HTTPException instance
        
    Returns:
        JSONResponse with standardized error format
    """
    request_id = getattr(request.state, 'request_id', str(uuid.uuid4()))
    
    # Map HTTP status codes to error codes
    error_code_map = {
        400: "BAD_REQUEST",
        401: "UNAUTHORIZED", 
        403: "FORBIDDEN",
        404: "NOT_FOUND",
        405: "METHOD_NOT_ALLOWED",
        409: "CONFLICT",
        422: "VALIDATION_ERROR",
        429: "RATE_LIMIT_EXCEEDED",
        500: "INTERNAL_SERVER_ERROR",
        502: "BAD_GATEWAY",
        503: "SERVICE_UNAVAILABLE",
        504: "GATEWAY_TIMEOUT"
    }
    
    error_code = error_code_map.get(exc.status_code, "HTTP_ERROR")
    
    # Log the error
    logger.warning(
        f"HTTP exception: {exc.detail}",
        extra={
            "error_code": error_code,
            "status_code": exc.status_code,
            "request_id": request_id,
            "path": request.url.path,
            "method": request.method
        }
    )
    
    return ResponseSerializer.error(
        message=str(exc.detail),
        error_code=error_code,
        status_code=exc.status_code,
        request_id=request_id
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """
    Handle Pydantic validation errors.
    
    Args:
        request: The FastAPI request object
        exc: The validation error instance
        
    Returns:
        JSONResponse with standardized validation error format
    """
    request_id = getattr(request.state, 'request_id', str(uuid.uuid4()))
    
    # Convert validation errors to our format
    errors = []
    for error in exc.errors():
        field_name = ".".join(str(loc) for loc in error["loc"])
        errors.append(ErrorDetail(
            field=field_name,
            message=error["msg"],
            code=error["type"]
        ))
    
    # Log the validation error
    logger.warning(
        f"Validation error: {len(errors)} field(s) failed validation",
        extra={
            "error_count": len(errors),
            "request_id": request_id,
            "path": request.url.path,
            "method": request.method,
            "errors": [{"field": e.field, "message": e.message} for e in errors]
        }
    )
    
    return ResponseSerializer.validation_error(
        errors=errors,
        message="Request validation failed",
        request_id=request_id
    )


async def pydantic_validation_exception_handler(request: Request, exc: PydanticValidationError) -> JSONResponse:
    """
    Handle Pydantic validation errors from model validation.
    
    Args:
        request: The FastAPI request object
        exc: The Pydantic validation error instance
        
    Returns:
        JSONResponse with standardized validation error format
    """
    request_id = getattr(request.state, 'request_id', str(uuid.uuid4()))
    
    # Convert validation errors to our format
    errors = []
    for error in exc.errors():
        field_name = ".".join(str(loc) for loc in error["loc"])
        errors.append(ErrorDetail(
            field=field_name,
            message=error["msg"],
            code=error["type"]
        ))
    
    # Log the validation error
    logger.warning(
        f"Model validation error: {len(errors)} field(s) failed validation",
        extra={
            "error_count": len(errors),
            "request_id": request_id,
            "path": request.url.path,
            "method": request.method,
            "errors": [{"field": e.field, "message": e.message} for e in errors]
        }
    )
    
    return ResponseSerializer.validation_error(
        errors=errors,
        message="Data validation failed",
        request_id=request_id
    )


async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """
    Handle unexpected exceptions.
    
    Args:
        request: The FastAPI request object
        exc: The exception instance
        
    Returns:
        JSONResponse with standardized error format
    """
    request_id = getattr(request.state, 'request_id', str(uuid.uuid4()))
    
    # Log the unexpected error with full traceback
    logger.error(
        f"Unexpected error: {str(exc)}",
        extra={
            "error_type": type(exc).__name__,
            "request_id": request_id,
            "path": request.url.path,
            "method": request.method,
            "traceback": traceback.format_exc()
        }
    )
    
    # Don't expose internal error details in production
    from ..config import settings
    if settings.API_ENV == "production":
        message = "An internal server error occurred"
        details = None
    else:
        message = f"Internal server error: {str(exc)}"
        details = {
            "error_type": type(exc).__name__,
            "traceback": traceback.format_exc()
        }
    
    return ResponseSerializer.error(
        message=message,
        error_code="INTERNAL_SERVER_ERROR",
        status_code=500,
        details=details,
        request_id=request_id
    )


def setup_error_handlers(app):
    """
    Register all error handlers with the FastAPI application.
    
    Args:
        app: The FastAPI application instance
    """
    # Custom exception handlers
    app.add_exception_handler(NugeException, nuge_exception_handler)
    app.add_exception_handler(HTTPException, http_exception_handler)
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(PydanticValidationError, pydantic_validation_exception_handler)
    
    # Catch-all exception handler
    app.add_exception_handler(Exception, generic_exception_handler)
    
    logger.info("Error handlers registered successfully") 