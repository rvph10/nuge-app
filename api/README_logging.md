# Nuge API Logging System

A comprehensive logging system designed for the Nuge API with structured logging, security-aware
filtering, and multiple output handlers.

## Features

- **Structured JSON Logging**: Machine-readable logs with consistent format
- **Security-Aware**: Automatically filters sensitive data from logs
- **Multiple Handlers**: Console (colored) and file (rotating) outputs
- **Request Tracing**: Unique request IDs for correlation
- **Performance Monitoring**: Built-in timing and performance logging
- **Business Event Tracking**: Structured logging for business activities
- **Configurable**: Environment-based configuration

## Quick Start

### 1. Configuration

Add logging settings to your `.env` file:

```env
# Logging Settings
LOG_LEVEL=INFO
LOG_TO_FILE=true
LOG_FILE_MAX_SIZE=10
LOG_FILE_BACKUP_COUNT=5
```

### 2. Initialize in Your Application

The logging system is automatically initialized in `main.py`:

```python
from .logging_config import setup_logging, get_logger

# Initialize logging (done in app lifespan)
setup_logging()

# Get a logger for your module
logger = get_logger(__name__)
```

### 3. Basic Usage

```python
from .logging_config import get_logger

logger = get_logger(__name__)

# Simple logging
logger.info("User created successfully")
logger.error("Database connection failed", exc_info=True)

# Structured logging with context
logger.info("Processing order", extra={
    "user_id": "123",
    "order_id": "456",
    "event_type": "order_processing"
})
```

## Advanced Usage

### Business Event Logging

```python
from .logging_config import log_business_event

log_business_event(
    logger=logger,
    event_type="vendor_created",
    message="New food truck vendor registered",
    user_id="user_123",
    vendor_id="vendor_456",
    additional_data={
        "vendor_type": "food_truck",
        "location": "downtown"
    }
)
```

### Security Event Logging

```python
from .logging_config import log_security_event

log_security_event(
    logger=logger,
    event_type="login_attempt",
    message="Failed login attempt",
    user_id="user_123",
    ip_address="192.168.1.1",
    severity="warning"
)
```

### Performance Monitoring

```python
from .example_usage import log_performance

@log_performance("database_query")
async def get_vendors_nearby(latitude: float, longitude: float):
    # Your function logic here
    return vendors
```

### Request Context Logging

```python
from .middleware import get_request_id

async def my_route_handler(request: Request):
    request_id = get_request_id(request)

    logger.info("Processing request", extra={
        "request_id": request_id,
        "event_type": "route_processing"
    })
```

## Log Output Examples

### Console Output (Development)

```
[14:30:15] INFO     src.users.service:create_user:45 - Creating new user
[14:30:16] ERROR    src.auth.service:authenticate:78 - Authentication failed
```

### File Output (JSON, Production)

```json
{
  "timestamp": "2024-01-15T14:30:15.123456",
  "level": "INFO",
  "logger": "src.users.service",
  "message": "Creating new user",
  "module": "service",
  "function": "create_user",
  "line": 45,
  "user_id": "user_123",
  "event_type": "user_creation"
}
```

## Configuration Options

| Setting                 | Description            | Default | Example                             |
| ----------------------- | ---------------------- | ------- | ----------------------------------- |
| `LOG_LEVEL`             | Minimum log level      | `INFO`  | `DEBUG`, `INFO`, `WARNING`, `ERROR` |
| `LOG_TO_FILE`           | Enable file logging    | `true`  | `true`, `false`                     |
| `LOG_FILE_MAX_SIZE`     | Max file size in MB    | `10`    | `5`, `20`, `50`                     |
| `LOG_FILE_BACKUP_COUNT` | Number of backup files | `5`     | `3`, `10`                           |

## File Structure

```
api/
├── logs/                          # Created automatically
│   ├── nuge-api.log              # Main application logs
│   ├── nuge-api.log.1            # Rotated log files
│   └── nuge-api-errors.log       # Error-only logs
├── src/
│   ├── logging_config.py         # Main logging configuration
│   ├── middleware/
│   │   ├── __init__.py
│   │   └── logging_middleware.py # Request/response middleware
│   └── example_usage.py          # Usage examples
```

## Security Features

### Sensitive Data Filtering

The logging system automatically filters sensitive information:

```python
# This data will be filtered
sensitive_data = {
    "user": "john",
    "password": "secret123",  # -> "[REDACTED]"
    "api_key": "sk_live_...", # -> "[REDACTED]"
    "token": "eyJ0eXAi...",   # -> "[REDACTED]"
}

logger.info("User data", extra={"data": sensitive_data})
```

### Filtered Fields

- `password`, `token`, `key`, `secret`
- `authorization`, `auth`, `cookie`, `session`
- `jwt`, `api_key`, `supabase_key`, `supabase_jwt_secret`

## Performance Considerations

- **File Rotation**: Prevents log files from growing too large
- **Async Middleware**: Non-blocking request/response logging
- **Efficient Filtering**: Minimal overhead for sensitive data filtering
- **Level-based Filtering**: Only processes logs at configured level or above

## Best Practices

### 1. Use Appropriate Log Levels

```python
logger.debug("Detailed diagnostic info")     # Development only
logger.info("General application flow")      # Normal operations
logger.warning("Something unexpected")       # Potential issues
logger.error("Error occurred", exc_info=True) # Errors with stack trace
logger.critical("System failure")           # Critical system issues
```

### 2. Include Context

```python
# Good: Include relevant context
logger.info("Order processed", extra={
    "order_id": order_id,
    "user_id": user_id,
    "amount": amount,
    "payment_method": payment_method
})

# Avoid: Generic messages without context
logger.info("Order processed")
```

### 3. Use Structured Data

```python
# Good: Structured data for analysis
logger.info("API response", extra={
    "endpoint": "/api/vendors",
    "method": "GET",
    "status_code": 200,
    "response_time_ms": 45.2,
    "user_id": "user_123"
})
```

### 4. Handle Exceptions Properly

```python
try:
    result = risky_operation()
except Exception as exc:
    logger.error(
        "Operation failed",
        extra={
            "operation": "risky_operation",
            "error_type": type(exc).__name__,
            "user_id": user_id
        },
        exc_info=True  # Include stack trace
    )
    raise
```

## Monitoring and Alerting

### Log Analysis

The structured JSON format makes it easy to:

- Query logs with tools like `jq`
- Import into monitoring systems (ELK, Grafana)
- Set up automated alerts on error patterns

### Key Metrics to Monitor

- Error rates by endpoint
- Response times
- Failed authentication attempts
- Business event patterns
- System resource usage

### Example Queries

```bash
# Count errors in the last hour
cat logs/nuge-api.log | jq -r 'select(.level == "ERROR")' | wc -l

# Find slow requests (>1000ms)
cat logs/nuge-api.log | jq -r 'select(.response_time_ms > 1000)'

# Security events by IP
cat logs/nuge-api.log | jq -r 'select(.event_type | startswith("security_"))' | jq -r '.ip_address' | sort | uniq -c
```

## Troubleshooting

### Common Issues

1. **Logs not appearing**: Check `LOG_LEVEL` and ensure it's not set too high
2. **Permission errors**: Ensure the application can write to the `logs/` directory
3. **Large log files**: Adjust `LOG_FILE_MAX_SIZE` and `LOG_FILE_BACKUP_COUNT`
4. **Performance impact**: Consider raising `LOG_LEVEL` in production

### Debug Mode

```python
# Enable debug logging for specific modules
import logging
logging.getLogger("src.vendors").setLevel(logging.DEBUG)
```

## Integration with External Systems

### Sending Logs to External Services

```python
# Example: Send critical errors to external monitoring
import requests

class ExternalNotificationHandler(logging.Handler):
    def emit(self, record):
        if record.levelno >= logging.CRITICAL:
            # Send to monitoring service
            pass
```

This logging system provides a solid foundation for monitoring and debugging your Nuge API
application while maintaining security and performance standards.
