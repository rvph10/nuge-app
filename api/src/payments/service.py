import stripe
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession
from stripe import StripeError

from src.payments.exceptions import (DatabaseOperationError,
                                     StripePaymentError, UnexpectedError)
from src.payments.models import Payment
from src.payments.schemas import PaymentCreate, PaymentResponse


class PaymentService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_payment_intent(
        self, data: PaymentCreate
    ) -> PaymentResponse:
        async with self.db.begin():
            try:
                # Create a database entry for the payment
                payment = Payment(
                    amount=data.amount,
                    currency=data.currency,
                    status="pending",
                )
                self.db.add(payment)
                await self.db.flush()

                # Create Stripe PaymentIntent
                intent = stripe.PaymentIntent.create(
                    amount=data.amount,
                    currency=data.currency,
                    description=data.description,
                    payment_method=data.payment_method_id,
                    confirm=True,
                    automatic_payment_methods={
                        "enabled": True,
                        "allow_redirects": "never",
                    },
                )

                # Update the payment record
                payment.stripe_payment_intent_id = intent["id"]
                payment.status = intent["status"]

                # Commit changes to the database
                await self.db.commit()

                return PaymentResponse(client_secret=intent["client_secret"])

            except StripeError as e:
                await self.db.rollback()
                raise StripePaymentError(f"Stripe error: {e.user_message}")

            except SQLAlchemyError as e:
                await self.db.rollback()
                raise DatabaseOperationError(f"Database operation failed: {e}")

            except Exception as e:
                await self.db.rollback()
                raise UnexpectedError(f"Unexpected error: {str(e)}")
