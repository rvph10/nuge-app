"""
Logging configuration module for Nuge API.

This module provides a centralized logging configuration with:
- Multiple log levels and handlers
- Structured logging with JSON formatting
- File rotation and retention policies
- Request/response logging middleware
- Security-aware logging (no sensitive data)
"""

import logging
import logging.handlers
import sys
from pathlib import Path
from typing import Dict, Any, Optional
import json
from datetime import datetime
import traceback

from .config import settings


class SecurityAwareJSONFormatter(logging.Formatter):
    """
    Custom JSON formatter that excludes sensitive information from logs.
    
    Filters out common sensitive fields like passwords, tokens, and API keys.
    """
    
    SENSITIVE_FIELDS = {
        "password", "token", "key", "secret", "authorization", 
        "auth", "cookie", "session", "jwt", "api_key",
        "supabase_key", "supabase_jwt_secret"
    }
    
    def format(self, record: logging.LogRecord) -> str:
        """Format log record as JSON with sensitive data filtered out."""
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        
        # Add exception information if present
        if record.exc_info:
            log_data["exception"] = {
                "type": record.exc_info[0].__name__ if record.exc_info[0] else None,
                "message": str(record.exc_info[1]) if record.exc_info[1] else None,
                "traceback": traceback.format_exception(*record.exc_info)
            }
        
        # Add extra fields if present, filtering sensitive data
        if hasattr(record, 'extra_data'):
            filtered_extra = self._filter_sensitive_data(record.extra_data)
            log_data.update(filtered_extra)
        
        return json.dumps(log_data, default=str, ensure_ascii=False)
    
    def _filter_sensitive_data(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Recursively filter sensitive data from dictionary."""
        if not isinstance(data, dict):
            return data
        
        filtered = {}
        for key, value in data.items():
            key_lower = key.lower()
            
            # Check if key contains sensitive information
            if any(sensitive in key_lower for sensitive in self.SENSITIVE_FIELDS):
                filtered[key] = "[REDACTED]"
            elif isinstance(value, dict):
                filtered[key] = self._filter_sensitive_data(value)
            elif isinstance(value, list):
                filtered[key] = [
                    self._filter_sensitive_data(item) if isinstance(item, dict) else item
                    for item in value
                ]
            else:
                filtered[key] = value
        
        return filtered


class ColoredConsoleFormatter(logging.Formatter):
    """
    Console formatter with color coding for different log levels.
    """
    
    COLORS = {
        'DEBUG': '\033[36m',      # Cyan
        'INFO': '\033[32m',       # Green
        'WARNING': '\033[33m',    # Yellow
        'ERROR': '\033[31m',      # Red
        'CRITICAL': '\033[35m',   # Magenta
    }
    RESET = '\033[0m'
    
    def format(self, record: logging.LogRecord) -> str:
        """Format log record with colors and proper structure."""
        color = self.COLORS.get(record.levelname, '')
        reset = self.RESET
        
        # Format: [TIME] LEVEL module:function:line - message
        log_format = (
            f"[{self.formatTime(record, self.datefmt)}] "
            f"{color}{record.levelname:8}{reset} "
            f"{record.name}:{record.funcName}:{record.lineno}{reset} - {record.getMessage()}"
        )
        
        # Handle exception info properly - check if it's not just a boolean
        if record.exc_info and record.exc_info is not True:
            log_format += f"\n{self.formatException(record.exc_info)}"
        
        return log_format


def setup_logging() -> None:
    """
    Set up logging configuration for the application.
    
    Creates handlers for:
    - Console output (colored, human-readable)
    - File output (JSON format, rotating)
    - Error file (errors and above only)
    """
    
    # Create logs directory
    logs_dir = Path("logs")
    logs_dir.mkdir(exist_ok=True)
    
    # Configure root logger
    root_logger = logging.getLogger()
    log_level = getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO)
    root_logger.setLevel(log_level if not settings.API_DEBUG else logging.DEBUG)
    
    # Clear existing handlers
    root_logger.handlers.clear()
    
    # Console handler with colors
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(log_level)
    console_handler.setFormatter(ColoredConsoleFormatter())
    root_logger.addHandler(console_handler)
    
    # File handlers (only if enabled)
    if settings.LOG_TO_FILE:
        # Main log file handler (rotating)
        file_handler = logging.handlers.RotatingFileHandler(
            filename=logs_dir / "nuge-api.log",
            maxBytes=settings.LOG_FILE_MAX_SIZE * 1024 * 1024,  # Convert MB to bytes
            backupCount=settings.LOG_FILE_BACKUP_COUNT,
            encoding='utf-8'
        )
        file_handler.setLevel(log_level)
        file_handler.setFormatter(SecurityAwareJSONFormatter())
        root_logger.addHandler(file_handler)
        
        # Error log file handler
        error_handler = logging.handlers.RotatingFileHandler(
            filename=logs_dir / "nuge-api-errors.log",
            maxBytes=settings.LOG_FILE_MAX_SIZE * 1024 * 1024 // 2,  # Half size for errors
            backupCount=settings.LOG_FILE_BACKUP_COUNT,
            encoding='utf-8'
        )
        error_handler.setLevel(logging.ERROR)
        error_handler.setFormatter(SecurityAwareJSONFormatter())
        root_logger.addHandler(error_handler)
    
    # Set specific logger levels
    logging.getLogger("uvicorn").setLevel(logging.INFO)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("asyncio").setLevel(logging.WARNING)


def get_logger(name: str) -> logging.Logger:
    """
    Get a logger instance with the specified name.
    
    Args:
        name: Logger name (typically __name__ of the module)
        
    Returns:
        Configured logger instance
    """
    return logging.getLogger(name)


def log_with_context(
    logger: logging.Logger,
    level: int,
    message: str,
    extra_data: Optional[Dict[str, Any]] = None,
    exc_info: bool = False
) -> None:
    """
    Log a message with additional context data.
    
    Args:
        logger: Logger instance
        level: Log level (logging.INFO, logging.ERROR, etc.)
        message: Log message
        extra_data: Additional context data to include
        exc_info: Whether to include exception information
    """
    if extra_data:
        # Create a new LogRecord with extra data
        record = logger.makeRecord(
            logger.name, level, "", 0, message, (), exc_info
        )
        record.extra_data = extra_data
        logger.handle(record)
    else:
        logger.log(level, message, exc_info=exc_info)


# Convenience functions for common logging patterns
def log_api_request(
    logger: logging.Logger,
    method: str,
    path: str,
    user_id: Optional[str] = None,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None
) -> None:
    """Log API request with context."""
    extra_data = {
        "request_method": method,
        "request_path": path,
        "user_id": user_id,
        "ip_address": ip_address,
        "user_agent": user_agent,
        "event_type": "api_request"
    }
    log_with_context(logger, logging.INFO, f"{method} {path}", extra_data)


def log_api_response(
    logger: logging.Logger,
    method: str,
    path: str,
    status_code: int,
    response_time_ms: float,
    user_id: Optional[str] = None
) -> None:
    """Log API response with context."""
    extra_data = {
        "request_method": method,
        "request_path": path,
        "response_status": status_code,
        "response_time_ms": response_time_ms,
        "user_id": user_id,
        "event_type": "api_response"
    }
    log_with_context(
        logger, 
        logging.INFO if status_code < 400 else logging.WARNING,
        f"{method} {path} - {status_code} ({response_time_ms:.2f}ms)",
        extra_data
    )


def log_business_event(
    logger: logging.Logger,
    event_type: str,
    message: str,
    user_id: Optional[str] = None,
    vendor_id: Optional[str] = None,
    additional_data: Optional[Dict[str, Any]] = None
) -> None:
    """Log business events (vendor actions, user activities, etc.)."""
    extra_data = {
        "event_type": f"business_{event_type}",
        "user_id": user_id,
        "vendor_id": vendor_id,
    }
    
    if additional_data:
        extra_data.update(additional_data)
    
    log_with_context(logger, logging.INFO, message, extra_data)


def log_security_event(
    logger: logging.Logger,
    event_type: str,
    message: str,
    user_id: Optional[str] = None,
    ip_address: Optional[str] = None,
    severity: str = "info"
) -> None:
    """Log security-related events."""
    extra_data = {
        "event_type": f"security_{event_type}",
        "user_id": user_id,
        "ip_address": ip_address,
        "severity": severity
    }
    
    level = {
        "info": logging.INFO,
        "warning": logging.WARNING,
        "error": logging.ERROR,
        "critical": logging.CRITICAL
    }.get(severity, logging.INFO)
    
    log_with_context(logger, level, message, extra_data) 