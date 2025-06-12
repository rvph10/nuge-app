class StripePaymentError(Exception):
    """Raised when there's an error with Stripe payment processing."""

    def __init__(self, message: str):
        self.message = message
        super().__init__(message)


class DatabaseOperationError(Exception):
    """Raised when a database operation fails."""

    def __init__(self, message: str):
        self.message = message
        super().__init__(message)


class UnexpectedError(Exception):
    """Raised for unexpected errors."""

    def __init__(self, message: str):
        self.message = message
        super().__init__(message)
