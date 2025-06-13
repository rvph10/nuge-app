"""
Request middleware for the Nuge API.

This module provides middleware for request tracking, ID generation,
and request context management.
"""

import uuid
import time
from typing import Callable
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from ..logging_config import get_logger

logger = get_logger(__name__)


class RequestTrackingMiddleware(BaseHTTPMiddleware):
    """
    Middleware to track requests with unique IDs and timing.
    
    Adds a unique request ID to each request state and logs request
    start/end times for monitoring and debugging purposes.
    """
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """
        Process the request and add tracking information.
        
        Args:
            request: The incoming request
            call_next: The next middleware/handler in the chain
            
        Returns:
            Response with added tracking headers
        """
        # Generate unique request ID
        request_id = str(uuid.uuid4())
        request.state.request_id = request_id
        
        # Add request ID to response headers for client tracking
        start_time = time.time()
        
        # Log request start
        logger.info(
            f"Request started: {request.method} {request.url.path}",
            extra={
                "request_id": request_id,
                "method": request.method,
                "path": request.url.path,
                "query_params": str(request.query_params),
                "client_ip": request.client.host if request.client else "unknown",
                "user_agent": request.headers.get("user-agent", "unknown"),
                "event_type": "request_start"
            }
        )
        
        try:
            # Process the request
            response = await call_next(request)
            
            # Calculate processing time
            process_time = time.time() - start_time
            
            # Add tracking headers to response
            response.headers["X-Request-ID"] = request_id
            response.headers["X-Process-Time"] = str(round(process_time * 1000, 2))  # milliseconds
            
            # Log request completion
            logger.info(
                f"Request completed: {request.method} {request.url.path}",
                extra={
                    "request_id": request_id,
                    "method": request.method,
                    "path": request.url.path,
                    "status_code": response.status_code,
                    "process_time_ms": round(process_time * 1000, 2),
                    "event_type": "request_end"
                }
            )
            
            return response
            
        except Exception as exc:
            # Calculate processing time even for errors
            process_time = time.time() - start_time
            
            # Log request error
            logger.error(
                f"Request failed: {request.method} {request.url.path}",
                extra={
                    "request_id": request_id,
                    "method": request.method,
                    "path": request.url.path,
                    "error": str(exc),
                    "error_type": type(exc).__name__,
                    "process_time_ms": round(process_time * 1000, 2),
                    "event_type": "request_error"
                }
            )
            
            # Re-raise the exception to be handled by error handlers
            raise exc


async def request_id_middleware(request: Request, call_next):
    """
    Simple middleware function to add request ID to request state.
    
    This is a simpler alternative to the RequestTrackingMiddleware class
    if you only need request ID functionality without full logging.
    
    Args:
        request: The incoming request
        call_next: The next middleware/handler in the chain
        
    Returns:
        Response with request ID in headers
    """
    # Generate and store request ID
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id
    
    # Process request
    response = await call_next(request)
    
    # Add request ID to response headers
    response.headers["X-Request-ID"] = request_id
    
    return response 