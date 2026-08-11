from typing import List, Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.core.exceptions import NotFoundError
from app.models.owner import Owner
from app.schemas.payment import PaymentCreateRequest, PaymentRefundRequest, PaymentResponse, PaymentReversalRequest, ReceiptResponse
from app.schemas.response import APIResponse
from app.services.payment_service import PaymentService

router = APIRouter(prefix="/payments", tags=["Owner Payments"])


@router.get("", response_model=APIResponse[List[PaymentResponse]])
def get_payments(
    loan_id: Optional[str] = None,
    customer_id: Optional[str] = None,
    status: Optional[str] = None,
    method: Optional[str] = None,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = PaymentService(db)
    payments = service.payment_repo.get_all(loan_id=loan_id, customer_id=customer_id, status=status, method=method)
    return APIResponse(data=[PaymentResponse.model_validate(p) for p in payments])


@router.post("", response_model=APIResponse[PaymentResponse])
def record_payment(
    req: PaymentCreateRequest,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = PaymentService(db)
    payment = service.record_payment(req, created_by=owner.full_name)
    return APIResponse(data=PaymentResponse.model_validate(payment), message="Payment recorded, receipt generated & double-entry journal posted")


@router.get("/{id}", response_model=APIResponse[PaymentResponse])
def get_payment_by_id(
    id: str,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = PaymentService(db)
    payment = service.payment_repo.get_by_id(id)
    if not payment:
        raise NotFoundError("Payment record not found.")
    return APIResponse(data=PaymentResponse.model_validate(payment))


@router.get("/{id}/receipt", response_model=APIResponse[ReceiptResponse])
def get_payment_receipt(
    id: str,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = PaymentService(db)
    receipt = service.payment_repo.get_receipt_by_payment_id(id)
    if not receipt:
        raise NotFoundError("Receipt not found for this payment.")
    return APIResponse(data=ReceiptResponse.model_validate(receipt))


@router.post("/{id}/reverse", response_model=APIResponse[dict])
def reverse_payment(
    id: str,
    req: PaymentReversalRequest,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = PaymentService(db)
    reversal = service.reverse_payment(id, req, owner.full_name)
    return APIResponse(data={"reversal_id": reversal.id, "payment_id": id}, message="Payment successfully reversed and accounting adjusted")
