from datetime import datetime
from decimal import Decimal
from typing import Optional
from pydantic import BaseModel, ConfigDict, field_validator


class PaymentCreateRequest(BaseModel):
    loan_id: str
    amount: Decimal
    principal_amount: Decimal
    interest_amount: Decimal
    other_amount: Decimal = Decimal("0.00")

    payment_method: str = "CASH"  # CASH, UPI, BANK_TRANSFER, CARD, CHEQUE, ONLINE_GATEWAY, OTHER
    payment_source: str = "OWNER_RECORDED"
    reference_number: Optional[str] = None
    idempotency_key: Optional[str] = None
    notes: Optional[str] = ""

    @field_validator("amount", "principal_amount", "interest_amount", "other_amount")
    @classmethod
    def validate_non_negative(cls, v: Decimal) -> Decimal:
        if v < Decimal("0.00"):
            raise ValueError("Financial amounts cannot be negative.")
        return v.quantize(Decimal("0.01"))


class PaymentReversalRequest(BaseModel):
    reason: str
    reference: Optional[str] = None


class PaymentRefundRequest(BaseModel):
    amount: Decimal
    reason: str
    reference: Optional[str] = None

    @field_validator("amount")
    @classmethod
    def validate_positive(cls, v: Decimal) -> Decimal:
        if v <= Decimal("0.00"):
            raise ValueError("Refund amount must be greater than zero.")
        return v.quantize(Decimal("0.01"))


class PaymentResponse(BaseModel):
    id: str
    payment_code: str
    loan_id: str
    customer_id: str
    amount: Decimal
    principal_amount: Decimal
    interest_amount: Decimal
    other_amount: Decimal
    currency: str
    payment_method: str
    payment_source: str
    status: str
    payment_date: datetime
    reference_number: Optional[str] = None
    idempotency_key: Optional[str] = None
    created_by: str

    model_config = ConfigDict(from_attributes=True)


class ReceiptResponse(BaseModel):
    id: int
    receipt_number: str
    payment_id: str
    customer_id: str
    loan_id: str
    issued_at: datetime
    total_amount: Decimal
    principal_amount: Decimal
    interest_amount: Decimal
    remaining_balance: Decimal
    currency: str
    payment_method: str
    document_reference: str

    model_config = ConfigDict(from_attributes=True)


class PaymentOrderCreateRequest(BaseModel):
    loan_id: str
    amount: Decimal
    principal_amount: Decimal
    interest_amount: Decimal


class PaymentOrderResponse(BaseModel):
    external_order_id: str
    amount: Decimal
    currency: str
    status: str
    disclaimer: str = "DEMO / SIMULATED PAYMENT ORDER"
