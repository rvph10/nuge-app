from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.config import get_db
from src.payments.exceptions import (DatabaseOperationError,
                                     StripePaymentError, UnexpectedError)
from src.payments.schemas import PaymentCreate, PaymentResponse
from src.payments.service import PaymentService
from src.payments.webhook_service import WebhookService

payment_router = APIRouter(prefix="/payments", tags=["payments"])


@payment_router.post("/create-intent", response_model=PaymentResponse)
async def create_payment_intent_route(
    data: PaymentCreate, session: AsyncSession = Depends(get_db)
):
    payment_service = PaymentService(db=session)
    try:
        return await payment_service.create_payment_intent(data)
    except StripePaymentError as e:
        raise HTTPException(status_code=400, detail=e.message)
    except DatabaseOperationError as e:
        raise HTTPException(status_code=500, detail=e.message)
    except UnexpectedError as e:
        raise HTTPException(status_code=500, detail=e.message)


@payment_router.post("/webhook")
async def stripe_webhook(
    request: Request, session: AsyncSession = Depends(get_db)
):
    """
    Handle incoming Stripe webhooks.
    """
    payload = await request.body()
    sig_header = request.headers["Stripe-Signature"]

    webhook_service = WebhookService(db=session)

    return await webhook_service.consume_webhook(payload, sig_header, session)
