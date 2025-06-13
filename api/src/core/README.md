# Core Response Serialization & Error Handling

This module provides standardized response formats and error handling for the Nuge API, ensuring
consistent client-server communication and improved debugging capabilities.

## Features

- **Standardized Response Format**: All API responses follow a consistent structure
- **Custom Exception Classes**: Type-safe error handling with proper HTTP status codes
- **Request Tracking**: Unique request IDs for debugging and monitoring
- **Comprehensive Error Logging**: Detailed error information for debugging
- **Validation Error Handling**: User-friendly validation error messages

## Response Format

All API responses follow this standardized format:

### Success Response

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    /* actual response payload */
  },
  "meta": {
    /* additional metadata */
  },
  "timestamp": "2024-01-01T12:00:00.000Z",
  "request_id": "uuid-string"
}
```

### Error Response

```json
{
  "success": false,
  "message": "Error description",
  "error_code": "ERROR_TYPE",
  "details": {
    /* additional error context */
  },
  "errors": [
    /* validation error details */
  ],
  "timestamp": "2024-01-01T12:00:00.000Z",
  "request_id": "uuid-string"
}
```

### Paginated Response

```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [
    /* array of items */
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_items": 100,
    "total_pages": 5,
    "has_next": true,
    "has_prev": false
  },
  "timestamp": "2024-01-01T12:00:00.000Z",
  "request_id": "uuid-string"
}
```

## Usage Examples

### Basic Success Response

```python
from fastapi import APIRouter, Request
from ..core import ResponseSerializer

router = APIRouter()

@router.get("/users/{user_id}")
async def get_user(user_id: str, request: Request):
    user = await get_user_from_db(user_id)

    return ResponseSerializer.success(
        data=user,
        message="User retrieved successfully",
        request_id=getattr(request.state, 'request_id', None)
    )
```

### Paginated Response

```python
@router.get("/users")
async def list_users(
    page: int = 1,
    per_page: int = 20,
    request: Request = None
):
    users, total = await get_users_paginated(page, per_page)

    return ResponseSerializer.paginated(
        items=users,
        page=page,
        per_page=per_page,
        total_items=total,
        message="Users retrieved successfully",
        request_id=getattr(request.state, 'request_id', None)
    )
```

### Error Handling with Custom Exceptions

```python
from ..core import ResponseSerializer, NotFoundError, ForbiddenError

@router.get("/users/{user_id}")
async def get_user(user_id: str, current_user: User):
    user = await get_user_from_db(user_id)

    if not user:
        raise NotFoundError(
            message="User not found",
            resource_type="user",
            resource_id=user_id
        )

    if not can_access_user(current_user, user):
        raise ForbiddenError(
            message="Access denied to this user",
            resource="user",
            action="read"
        )

    return ResponseSerializer.success(data=user)
```

### Resource Creation

```python
@router.post("/users")
async def create_user(user_data: UserCreate, request: Request):
    user = await create_user_in_db(user_data)

    return ResponseSerializer.created(
        data=user,
        message="User created successfully",
        request_id=getattr(request.state, 'request_id', None)
    )
```

## Available Exception Classes

### Base Exception

- `NugeException`: Base class for all custom exceptions

### HTTP Status-Based Exceptions

- `ValidationError` (422): Input validation failures
- `UnauthorizedError` (401): Authentication required
- `ForbiddenError` (403): Access denied
- `NotFoundError` (404): Resource not found
- `ConflictError` (409): Resource conflicts (e.g., duplicate email)
- `ServerError` (500): Internal server errors

### Specialized Exceptions

- `DatabaseError`: Database operation failures
- `ExternalServiceError`: External API/service failures

## ResponseSerializer Methods

### Success Responses

- `success()`: Standard 200 success response
- `created()`: 201 resource created response
- `no_content()`: 204 operation completed response

### Error Responses

- `error()`: Generic error response
- `validation_error()`: 422 validation error with field details
- `not_found()`: 404 resource not found
- `forbidden()`: 403 access denied
- `unauthorized()`: 401 authentication required

### Specialized Responses

- `paginated()`: Paginated list response with metadata

## Request Tracking

Every request gets a unique ID for tracking and debugging:

```python
@router.get("/example")
async def example_endpoint(request: Request):
    request_id = getattr(request.state, 'request_id', None)

    # Use request_id in logs and responses
    logger.info("Processing request", extra={"request_id": request_id})

    return ResponseSerializer.success(
        data={"result": "success"},
        request_id=request_id
    )
```

The request ID is automatically included in:

- Response headers (`X-Request-ID`)
- Log entries
- Error responses
- Response body

## Error Logging

All errors are automatically logged with context:

```python
# This will be automatically logged by the error handler
raise NotFoundError(
    message="User not found",
    resource_type="user",
    resource_id="123"
)
```

Log entry includes:

- Request ID
- Error type and message
- HTTP method and path
- User context (if available)
- Stack trace (for server errors)

## Migration Guide

### From Old Format

```python
# OLD
@router.get("/users/{user_id}")
async def get_user(user_id: str):
    user = await get_user_from_db(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

### To New Format

```python
# NEW
@router.get("/users/{user_id}", response_model=None)
async def get_user(user_id: str, request: Request):
    user = await get_user_from_db(user_id)
    if not user:
        raise NotFoundError(
            message="User not found",
            resource_type="user",
            resource_id=user_id
        )

    return ResponseSerializer.success(
        data=user,
        message="User retrieved successfully",
        request_id=getattr(request.state, 'request_id', None)
    )
```

## Configuration

The error handling system respects environment settings:

- **Development**: Full error details and stack traces
- **Production**: Sanitized error messages for security

## Best Practices

1. **Always use custom exceptions** instead of HTTPException
2. **Include request_id** in all responses for tracking
3. **Set response_model=None** to let ResponseSerializer handle the model
4. **Provide meaningful error messages** for better user experience
5. **Use appropriate HTTP status codes** via the right exception types
6. **Include resource context** in error details when applicable

## Response Headers

All responses include these headers:

- `X-Request-ID`: Unique request identifier
- `X-Process-Time`: Request processing time in milliseconds
