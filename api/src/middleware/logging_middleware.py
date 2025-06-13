"""
Logging middleware for FastAPI request/response logging.

This middleware captures and logs HTTP requests and responses with:
- Request details (method, path, headers, IP)
- Response details (status code, response time)
- User context when available
- Error handling and exception logging
"""

import logging
import time
import uuid
from typing import Callable, Optional

from fastapi import Request, Response
from fastapi.responses import JSONResponse

from ..logging_config import (
    get_logger,
    log_api_request,
    log_api_response,
    log_with_context,
)

logger = get_logger(__name__)


async def logging_middleware(request: Request, call_next: Callable) -> Response:
    """
    Middleware to log HTTP requests and responses.

    Args:
        request: FastAPI request object
        call_next: Next middleware/route handler

    Returns:
        Response object
    """
    # Generate unique request ID for tracing
    request_id = str(uuid.uuid4())

    # Extract request information
    start_time = time.time()
    method = request.method
    path = request.url.path
    query_params = str(request.query_params) if request.query_params else None

    # Extract client information
    client_ip = _get_client_ip(request)
    user_agent = request.headers.get("user-agent")
    user_id = _extract_user_id(request)

    # Log request
    log_api_request(
        logger=logger,
        method=method,
        path=path,
        user_id=user_id,
        ip_address=client_ip,
        user_agent=user_agent,
    )

    # Add request ID to state for access in route handlers
    request.state.request_id = request_id

    try:
        # Process request
        response = await call_next(request)

        # Calculate response time
        response_time_ms = (time.time() - start_time) * 1000

        # Log response
        log_api_response(
            logger=logger,
            method=method,
            path=path,
            status_code=response.status_code,
            response_time_ms=response_time_ms,
            user_id=user_id,
        )

        # Add request ID to response headers for debugging
        response.headers["X-Request-ID"] = request_id

        return response

    except Exception as exc:
        # Calculate response time for error
        response_time_ms = (time.time() - start_time) * 1000

        # Log exception with context
        log_with_context(
            logger=logger,
            level=logging.ERROR,
            message=f"Request failed: {method} {path}",
            extra_data={
                "request_id": request_id,
                "request_method": method,
                "request_path": path,
                "user_id": user_id,
                "ip_address": client_ip,
                "response_time_ms": response_time_ms,
                "exception_type": type(exc).__name__,
                "exception_message": str(exc),
                "event_type": "api_error",
            },
            exc_info=True,
        )

        # Return generic error response
        error_response = JSONResponse(
            status_code=500,
            content={"error": "Internal server error", "request_id": request_id},
        )
        error_response.headers["X-Request-ID"] = request_id

        return error_response


def _get_client_ip(request: Request) -> str:
    """
    Extract client IP address from request headers.

    Handles various proxy headers in order of preference.

    Args:
        request: FastAPI request object

    Returns:
        Client IP address as string
    """
    # Check for forwarded headers (most common in production)
    forwarded_for = request.headers.get("x-forwarded-for")
    if forwarded_for:
        # X-Forwarded-For can contain multiple IPs, take the first one
        return forwarded_for.split(",")[0].strip()

    # Check for real IP header (used by some proxies)
    real_ip = request.headers.get("x-real-ip")
    if real_ip:
        return real_ip

    # Check for Cloudflare connecting IP
    cf_connecting_ip = request.headers.get("cf-connecting-ip")
    if cf_connecting_ip:
        return cf_connecting_ip

    # Fallback to direct client IP
    if request.client:
        return request.client.host

    return "unknown"


def _extract_user_id(request: Request) -> Optional[str]:
    """
    Extract user ID from request if authenticated.

    This function should be adapted based on your authentication method.
    Currently assumes user information is stored in request.state.user

    Args:
        request: FastAPI request object

    Returns:
        User ID if authenticated, None otherwise
    """
    # Check if user is authenticated (adapt based on your auth implementation)
    if hasattr(request.state, "user") and request.state.user:
        # Assuming user object has an 'id' attribute
        return getattr(request.state.user, "id", None)

    # Alternative: Extract from JWT token if stored in state
    if hasattr(request.state, "user_id"):
        return request.state.user_id

    return None


def get_request_id(request: Request) -> Optional[str]:
    """
    Get the request ID from the request state.

    Useful for correlating logs within a single request.

    Args:
        request: FastAPI request object

    Returns:
        Request ID if available, None otherwise
    """
    return getattr(request.state, "request_id", None)
