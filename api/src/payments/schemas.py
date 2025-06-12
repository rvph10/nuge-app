from pydantic import BaseModel, Field


class PaymentCreate(BaseModel):
    amount: int = Field(..., description="Amount in cents")
    currency: str = Field(..., description="Currency code, e.g., 'usd'")
    description: str = Field(..., description="Payment description")
    payment_method_id: str = Field(..., description="Payment method id")


class PaymentResponse(BaseModel):
    client_secret: str = Field(
        ..., description="Client secret for the payment intent"
    )
