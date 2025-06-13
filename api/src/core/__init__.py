"""
Core utilities for the Nuge API.

This module contains shared utilities including response serializers,
error handling, and common schemas used across the application.
"""

from .exceptions import (
    ConflictError,
    ForbiddenError,
    NotFoundError,
    NugeException,
    ServerError,
    UnauthorizedError,
    ValidationError,
)
from .response import ErrorResponse, ResponseSerializer, SuccessResponse

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
    "ServerError",
]
