import stripe
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from stripe import StripeError

from src.payments.configs import stripe_settings
from src.payments.webhook_utils import handle_payment_succeeded


class WebhookService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def consume_webhook(
        self, payload: bytes, sig_header: str, session: AsyncSession
    ) -> None:
        try:
            event = stripe.Webhook.construct_event(
                payload, sig_header, stripe_settings.stripe_webhook_secret
            )

            match event["type"]:
                case "payment_intent.succeeded":
                    await handle_payment_succeeded(event, session)
                case _:
                    print(f"Unhandled event type: {event['type']}")

        except StripeError:
            raise HTTPException(
                status_code=400, detail="Webhook signature verification failed"
            )
        except Exception as e:
            raise HTTPException(
                status_code=400, detail=f"Webhook error: {str(e)}"
            )
