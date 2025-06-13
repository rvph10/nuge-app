"""
Core utilities for the Nuge API.

This module contains shared utilities including response serializers,
error handling, and common schemas used across the application.
"""

from .response import ResponseSerializer, ErrorResponse, SuccessResponse
from .exceptions import (
    NugeException,
    ValidationError,
    NotFoundError,
    ForbiddenError,
    UnauthorizedError,
    ConflictError,
    ServerError
)

__all__ = [
    "ResponseSerializer",
    "ErrorResponse", 
    "SuccessResponse",
    "NugeException",
    "ValidationError",
    "NotFoundError",
    "ForbiddenError",
    "UnauthorizedError",
    "ConflictError",
    "ServerError"
] 