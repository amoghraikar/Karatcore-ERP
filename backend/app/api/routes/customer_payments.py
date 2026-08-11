from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_customer
from app.core.database import get_db
from app.core.exceptions import NotFoundError
from app.models.customer import Customer
from app.schemas.payment import PaymentOrderCreateRequest, PaymentOrderResponse, PaymentResponse, ReceiptResponse
from app.schemas.response import APIResponse
from app.services.payment_provider.mock_gateway import MockPaymentGatewayProvider
from app.services.payment_service import PaymentService

router = APIRouter(prefix="/customer", tags=["Customer Payments Portal"])


@router.get("/payments", response_model=APIResponse[List[PaymentResponse]])
def get_customer_payments(
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = PaymentService(db)
    payments = service.payment_repo.get_all(customer_id=customer.id)
    return APIResponse(data=[PaymentResponse.model_validate(p) for p in payments])


@router.get("/payments/{id}", response_model=APIResponse[PaymentResponse])
def get_customer_payment_by_id(
    id: str,
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = PaymentService(db)
    payment = service.payment_repo.get_by_id(id)

    # STRICT CUSTOMER DATA ISOLATION ENFORCEMENT
    if not payment or payment.customer_id != customer.id:
        raise NotFoundError("Access Restricted: Payment record not found or does not belong to your account.")

    return APIResponse(data=PaymentResponse.model_validate(payment))


@router.get("/payments/{id}/receipt", response_model=APIResponse[ReceiptResponse])
def get_customer_receipt(
    id: str,
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = PaymentService(db)
    payment = service.payment_repo.get_by_id(id)

    # STRICT CUSTOMER DATA ISOLATION ENFORCEMENT
    if not payment or payment.customer_id != customer.id:
        raise NotFoundError("Access Restricted: Receipt not found or does not belong to your account.")

    receipt = service.payment_repo.get_receipt_by_payment_id(id)
    if not receipt:
        raise NotFoundError("Receipt record not found.")

    return APIResponse(data=ReceiptResponse.model_validate(receipt))


@router.post("/payment-orders", response_model=APIResponse[PaymentOrderResponse])
def create_payment_order(
    req: PaymentOrderCreateRequest,
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    provider = MockPaymentGatewayProvider()
    order = provider.create_payment_order(customer.id, req.loan_id, req.amount)
    return APIResponse(
        data=PaymentOrderResponse(
            external_order_id=order["external_order_id"],
            amount=order["amount"],
            currency=order["currency"],
            status=order["status"],
            disclaimer=order["disclaimer"],
        ),
        message="Simulated online payment order created",
    )
