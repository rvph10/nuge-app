from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from src.payments.models import Payment


async def handle_payment_succeeded(event: dict, session: AsyncSession):
    """
    Handle payment_intent.succeeded events from Stripe.
    """
    payment_intent = event["data"]["object"]
    payment_intent_id = payment_intent["id"]

    # Check if the payment already exists in the database
    result = await session.execute(
        select(Payment).where(
            Payment.stripe_payment_intent_id == payment_intent_id
        )
    )
    payment = result.scalar_one_or_none()

    if payment:
        # If payment exists, update its status
        payment.status = "succeeded"
    else:
        # If payment does not exist, create a new entry
        payment = Payment(
            stripe_payment_intent_id=payment_intent_id,
            amount=payment_intent["amount"],
            currency=payment_intent["currency"],
            status="succeeded",
        )
        session.add(payment)

    await session.commit()
