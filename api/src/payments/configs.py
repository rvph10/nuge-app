import stripe
from pydantic_settings import BaseSettings


class StripeSettings(BaseSettings):
    stripe_api_key: str
    stripe_webhook_secret: str

    class Config:
        env_file = ".env"
        extra = "ignore"


stripe_settings = StripeSettings()

stripe.api_key = stripe_settings.stripe_api_key
