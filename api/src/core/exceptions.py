"""
Custom exception classes for the Nuge API.

This module defines all custom exceptions used throughout the application,
providing consistent error handling and HTTP status codes.
"""

from typing import Optional, Dict, Any
from fastapi import status


class NugeException(Exception):
    """
    Base exception class for all Nuge-specific errors.
    
    Args:
        message: Human-readable error message
        status_code: HTTP status code to return
        error_code: Application-specific error code for client handling
        details: Additional error details or context
    """
    
    def __init__(
        self,
        message: str,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        error_code: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        self.message = message
        self.status_code = status_code
        self.error_code = error_code or self.__class__.__name__.upper()
        self.details = details or {}
        super().__init__(self.message)


class ValidationError(NugeException):
    """Raised when input validation fails."""
    
    def __init__(
        self,
        message: str = "Validation failed",
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(
            message=message,
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            error_code="VALIDATION_ERROR",
            details=details
        )


class NotFoundError(NugeException):
    """Raised when a requested resource is not found."""
    
    def __init__(
        self,
        message: str = "Resource not found",
        resource_type: Optional[str] = None,
        resource_id: Optional[str] = None
    ):
        details = {}
        if resource_type:
            details["resource_type"] = resource_type
        if resource_id:
            details["resource_id"] = resource_id
            
        super().__init__(
            message=message,
            status_code=status.HTTP_404_NOT_FOUND,
            error_code="NOT_FOUND",
            details=details
        )


class UnauthorizedError(NugeException):
    """Raised when authentication is required but not provided or invalid."""
    
    def __init__(
        self,
        message: str = "Authentication required",
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(
            message=message,
            status_code=status.HTTP_401_UNAUTHORIZED,
            error_code="UNAUTHORIZED",
            details=details
        )


class ForbiddenError(NugeException):
    """Raised when user lacks permission to access a resource."""
    
    def __init__(
        self,
        message: str = "Access forbidden",
        resource: Optional[str] = None,
        action: Optional[str] = None
    ):
        details = {}
        if resource:
            details["resource"] = resource
        if action:
            details["action"] = action
            
        super().__init__(
            message=message,
            status_code=status.HTTP_403_FORBIDDEN,
            error_code="FORBIDDEN",
            details=details
        )


class ConflictError(NugeException):
    """Raised when a resource conflict occurs (e.g., duplicate email)."""
    
    def __init__(
        self,
        message: str = "Resource conflict",
        conflict_field: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        if conflict_field and details is None:
            details = {"conflict_field": conflict_field}
        elif conflict_field:
            details["conflict_field"] = conflict_field
            
        super().__init__(
            message=message,
            status_code=status.HTTP_409_CONFLICT,
            error_code="CONFLICT",
            details=details
        )


class ServerError(NugeException):
    """Raised for internal server errors."""
    
    def __init__(
        self,
        message: str = "Internal server error",
        details: Optional[Dict[str, Any]] = None
    ):
        super().__init__(
            message=message,
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            error_code="SERVER_ERROR",
            details=details
        )


class DatabaseError(ServerError):
    """Raised when database operations fail."""
    
    def __init__(
        self,
        message: str = "Database operation failed",
        operation: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        if operation and details is None:
            details = {"operation": operation}
        elif operation:
            details["operation"] = operation
            
        super().__init__(message=message, details=details)


class ExternalServiceError(ServerError):
    """Raised when external service calls fail."""
    
    def __init__(
        self,
        message: str = "External service error",
        service: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        if service and details is None:
            details = {"service": service}
        elif service:
            details["service"] = service
            
        super().__init__(message=message, details=details) 