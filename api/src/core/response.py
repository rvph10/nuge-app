"""
Response serializers for consistent API responses.

This module provides standardized response formats for all API endpoints,
including success responses, error responses, and paginated responses.
"""

from typing import Optional, Dict, Any, List, Generic, TypeVar, Union
from datetime import datetime
from pydantic import BaseModel, Field
from fastapi.responses import JSONResponse

T = TypeVar('T')


class BaseResponse(BaseModel):
    """Base response model with common fields."""
    
    success: bool = Field(..., description="Indicates if the request was successful")
    message: str = Field(..., description="Human-readable message describing the response")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="Response timestamp in UTC")
    request_id: Optional[str] = Field(None, description="Unique request identifier for tracking")
    
    class Config:
        json_encoders = {
            datetime: lambda dt: dt.isoformat()
        }
    
    def dict_with_encoders(self, exclude_none: bool = True, **kwargs) -> Dict[str, Any]:
        """Convert to dict with proper datetime encoding."""
        data = self.dict(exclude_none=exclude_none, **kwargs)
        
        # Apply datetime encoding manually
        def encode_datetime(obj):
            if isinstance(obj, datetime):
                return obj.isoformat()
            elif isinstance(obj, dict):
                return {k: encode_datetime(v) for k, v in obj.items()}
            elif isinstance(obj, list):
                return [encode_datetime(item) for item in obj]
            return obj
        
        return encode_datetime(data)


class SuccessResponse(BaseResponse, Generic[T]):
    """
    Standard success response format.
    
    Args:
        data: The actual response payload
        message: Success message
        meta: Additional metadata (e.g., pagination info)
    """
    
    success: bool = Field(True, description="Always True for success responses")
    data: Optional[T] = Field(None, description="Response payload data")
    meta: Optional[Dict[str, Any]] = Field(None, description="Additional response metadata")


class ErrorDetail(BaseModel):
    """Detailed error information."""
    
    field: Optional[str] = Field(None, description="Field name that caused the error (for validation errors)")
    message: str = Field(..., description="Error message")
    code: Optional[str] = Field(None, description="Error code for programmatic handling")


class ErrorResponse(BaseResponse):
    """
    Standard error response format.
    
    Args:
        message: Error message
        error_code: Application-specific error code
        details: Detailed error information
        errors: List of specific error details (for validation errors)
    """
    
    success: bool = Field(False, description="Always False for error responses")
    error_code: str = Field(..., description="Application-specific error code")
    details: Optional[Dict[str, Any]] = Field(None, description="Additional error details")
    errors: Optional[List[ErrorDetail]] = Field(None, description="List of specific error details")


class PaginationMeta(BaseModel):
    """Pagination metadata for list responses."""
    
    page: int = Field(..., ge=1, description="Current page number")
    per_page: int = Field(..., ge=1, le=100, description="Items per page")
    total_items: int = Field(..., ge=0, description="Total number of items")
    total_pages: int = Field(..., ge=0, description="Total number of pages")
    has_next: bool = Field(..., description="Whether there are more pages")
    has_prev: bool = Field(..., description="Whether there are previous pages")


class PaginatedResponse(SuccessResponse[List[T]]):
    """
    Paginated response format for list endpoints.
    
    Extends SuccessResponse with pagination-specific metadata.
    """
    
    data: List[T] = Field(..., description="List of items in current page")
    pagination: PaginationMeta = Field(..., description="Pagination metadata")
    
    # Override meta to include pagination info for backward compatibility
    @property
    def meta(self) -> Dict[str, Any]:
        return {"pagination": self.pagination.dict()}


class ResponseSerializer:
    """
    Utility class for creating standardized API responses.
    
    Provides static methods for creating consistent response formats
    across all API endpoints.
    """
    
    @staticmethod
    def success(
        data: Optional[T] = None,
        message: str = "Success",
        meta: Optional[Dict[str, Any]] = None,
        status_code: int = 200,
        request_id: Optional[str] = None
    ) -> JSONResponse:
        """
        Create a successful response.
        
        Args:
            data: Response payload
            message: Success message
            meta: Additional metadata
            status_code: HTTP status code
            request_id: Request tracking ID
            
        Returns:
            JSONResponse with standardized success format
        """
        response_data = SuccessResponse[T](
            data=data,
            message=message,
            meta=meta,
            request_id=request_id
        )
        
        return JSONResponse(
            status_code=status_code,    
            content=response_data.dict_with_encoders(exclude_none=True),
            headers={"Content-Type": "application/json"}
        )
    
    @staticmethod
    def error(
        message: str,
        error_code: str,
        status_code: int = 500,
        details: Optional[Dict[str, Any]] = None,
        errors: Optional[List[ErrorDetail]] = None,
        request_id: Optional[str] = None
    ) -> JSONResponse:
        """
        Create an error response.
        
        Args:
            message: Error message
            error_code: Application-specific error code
            status_code: HTTP status code
            details: Additional error details
            errors: List of specific error details
            request_id: Request tracking ID
            
        Returns:
            JSONResponse with standardized error format
        """
        response_data = ErrorResponse(
            message=message,
            error_code=error_code,
            details=details,
            errors=errors,
            request_id=request_id
        )
        
        return JSONResponse(
            status_code=status_code,
            content=response_data.dict_with_encoders(exclude_none=True)
        )
    
    @staticmethod
    def paginated(
        items: List[T],
        page: int,
        per_page: int,
        total_items: int,
        message: str = "Data retrieved successfully",
        request_id: Optional[str] = None
    ) -> JSONResponse:
        """
        Create a paginated response.
        
        Args:
            items: List of items in current page
            page: Current page number  
            per_page: Items per page
            total_items: Total number of items
            message: Success message
            request_id: Request tracking ID
            
        Returns:
            JSONResponse with paginated format
        """
        import math
        
        total_pages = math.ceil(total_items / per_page) if total_items > 0 else 0
        has_next = page < total_pages
        has_prev = page > 1
        
        pagination = PaginationMeta(
            page=page,
            per_page=per_page,
            total_items=total_items,
            total_pages=total_pages,
            has_next=has_next,
            has_prev=has_prev
        )
        
        response_data = PaginatedResponse[T](
            data=items,
            message=message,
            pagination=pagination,
            request_id=request_id
        )
        
        return JSONResponse(
            status_code=200,
            content=response_data.dict_with_encoders(exclude_none=True)
        )
    
    @staticmethod
    def created(
        data: Optional[T] = None,
        message: str = "Resource created successfully",
        request_id: Optional[str] = None
    ) -> JSONResponse:
        """Create a 201 Created response."""
        return ResponseSerializer.success(
            data=data,
            message=message,
            status_code=201,
            request_id=request_id
        )
    
    @staticmethod
    def no_content(
        message: str = "Operation completed successfully",
        request_id: Optional[str] = None
    ) -> JSONResponse:
        """Create a 204 No Content response."""
        return ResponseSerializer.success(
            message=message,
            status_code=204,
            request_id=request_id
        )
    
    @staticmethod  
    def validation_error(
        errors: List[ErrorDetail],
        message: str = "Validation failed",
        request_id: Optional[str] = None
    ) -> JSONResponse:
        """Create a validation error response."""
        return ResponseSerializer.error(
            message=message,
            error_code="VALIDATION_ERROR",
            status_code=422,
            errors=errors,
            request_id=request_id
        )
    
    @staticmethod
    def not_found(
        message: str = "Resource not found",
        resource_type: Optional[str] = None,
        resource_id: Optional[str] = None,
        request_id: Optional[str] = None
    ) -> JSONResponse:
        """Create a 404 Not Found response."""
        details = {}
        if resource_type:
            details["resource_type"] = resource_type
        if resource_id:
            details["resource_id"] = resource_id
            
        return ResponseSerializer.error(
            message=message,
            error_code="NOT_FOUND",
            status_code=404,
            details=details if details else None,
            request_id=request_id
        )
    
    @staticmethod
    def forbidden(
        message: str = "Access forbidden",
        resource: Optional[str] = None,
        action: Optional[str] = None,
        request_id: Optional[str] = None
    ) -> JSONResponse:
        """Create a 403 Forbidden response."""
        details = {}
        if resource:
            details["resource"] = resource
        if action:
            details["action"] = action
            
        return ResponseSerializer.error(
            message=message,
            error_code="FORBIDDEN", 
            status_code=403,
            details=details if details else None,
            request_id=request_id
        )
    
    @staticmethod
    def unauthorized(
        message: str = "Authentication required",
        request_id: Optional[str] = None
    ) -> JSONResponse:
        """Create a 401 Unauthorized response."""
        return ResponseSerializer.error(
            message=message,
            error_code="UNAUTHORIZED",
            status_code=401,
            request_id=request_id
        ) 