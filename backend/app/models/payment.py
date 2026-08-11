from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class LoanPayment(BaseModel):
    __tablename__ = "loan_payments"

    id = Column(String(50), primary_key=True, index=True)
    payment_code = Column(String(50), unique=True, index=True, nullable=False)
    loan_id = Column(String(50), ForeignKey("loans.id"), nullable=False, index=True)
    customer_id = Column(String(50), ForeignKey("customers.id"), nullable=False, index=True)

    # Financial Precision using Numeric(12, 2)
    amount = Column(Numeric(12, 2), nullable=False)
    principal_amount = Column(Numeric(12, 2), nullable=False)
    interest_amount = Column(Numeric(12, 2), nullable=False)
    other_amount = Column(Numeric(12, 2), default=0.00, nullable=False)

    currency = Column(String(10), default="INR", nullable=False)
    payment_method = Column(String(50), nullable=False)  # CASH, UPI, BANK_TRANSFER, CARD, CHEQUE, ONLINE_GATEWAY, OTHER
    payment_source = Column(String(50), default="OWNER_RECORDED", nullable=False)  # OWNER_RECORDED, CUSTOMER_ONLINE, EXTERNAL_GATEWAY, BANK_IMPORT
    status = Column(String(50), default="SUCCESS", nullable=False, index=True)  # PENDING, PROCESSING, SUCCESS, FAILED, CANCELLED, REVERSED, REFUNDED

    payment_date = Column(DateTime, nullable=False, index=True)
    reference_number = Column(String(100), nullable=True)
    external_transaction_id = Column(String(100), unique=True, nullable=True, index=True)
    idempotency_key = Column(String(100), unique=True, nullable=True, index=True)
    notes = Column(String(500), default="", nullable=False)
    created_by = Column(String(100), default="Owner Counter", nullable=False)

    loan = relationship("Loan", back_populates="payments")
    receipt = relationship("Receipt", back_populates="payment", uselist=False)
    reversals = relationship("PaymentReversal", back_populates="payment")
    refunds = relationship("PaymentRefund", back_populates="payment")


class Receipt(BaseModel):
    __tablename__ = "receipts"

    id = Column(Integer, primary_key=True, index=True)
    receipt_number = Column(String(50), unique=True, index=True, nullable=False)  # KC-RCP-2026-XXXXXX
    payment_id = Column(String(50), ForeignKey("loan_payments.id"), nullable=False, unique=True, index=True)
    customer_id = Column(String(50), nullable=False, index=True)
    loan_id = Column(String(50), nullable=False, index=True)
    issued_at = Column(DateTime, nullable=False)

    total_amount = Column(Numeric(12, 2), nullable=False)
    principal_amount = Column(Numeric(12, 2), nullable=False)
    interest_amount = Column(Numeric(12, 2), nullable=False)
    remaining_balance = Column(Numeric(12, 2), nullable=False)

    currency = Column(String(10), default="INR", nullable=False)
    payment_method = Column(String(50), nullable=False)
    document_reference = Column(String(255), nullable=False)

    payment = relationship("LoanPayment", back_populates="receipt")


class PaymentReversal(BaseModel):
    __tablename__ = "payment_reversals"

    id = Column(Integer, primary_key=True, index=True)
    payment_id = Column(String(50), ForeignKey("loan_payments.id"), nullable=False, index=True)
    amount = Column(Numeric(12, 2), nullable=False)
    reason = Column(String(500), nullable=False)
    reference = Column(String(100), nullable=True)
    created_by = Column(String(100), nullable=False)
    created_at = Column(DateTime, nullable=False)

    payment = relationship("LoanPayment", back_populates="reversals")


class PaymentRefund(BaseModel):
    __tablename__ = "payment_refunds"

    id = Column(Integer, primary_key=True, index=True)
    payment_id = Column(String(50), ForeignKey("loan_payments.id"), nullable=False, index=True)
    amount = Column(Numeric(12, 2), nullable=False)
    reason = Column(String(500), nullable=False)
    reference = Column(String(100), nullable=True)
    status = Column(String(50), default="SUCCESS", nullable=False)
    created_by = Column(String(100), nullable=False)
    created_at = Column(DateTime, nullable=False)

    payment = relationship("LoanPayment", back_populates="refunds")


class PaymentTransaction(BaseModel):
    __tablename__ = "payment_transactions"

    id = Column(String(50), primary_key=True, index=True)
    provider = Column(String(50), default="DEMO_MOCK_GATEWAY", nullable=False)
    external_order_id = Column(String(100), unique=True, nullable=False, index=True)
    external_transaction_id = Column(String(100), nullable=True, index=True)
    customer_id = Column(String(50), nullable=False, index=True)
    loan_id = Column(String(50), nullable=False, index=True)
    status = Column(String(50), default="CREATED", nullable=False)  # CREATED, PENDING, SUCCESS, FAILED, CANCELLED, REFUNDED
    amount = Column(Numeric(12, 2), nullable=False)
    currency = Column(String(10), default="INR", nullable=False)


class PaymentWebhookEvent(BaseModel):
    __tablename__ = "payment_webhook_events"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(String(100), unique=True, nullable=False, index=True)
    provider = Column(String(50), nullable=False)
    event_type = Column(String(100), nullable=False)
    processed = Column(DateTime, nullable=False)


class PaymentReconciliation(BaseModel):
    __tablename__ = "payment_reconciliations"

    id = Column(Integer, primary_key=True, index=True)
    payment_id = Column(String(50), nullable=True, index=True)
    external_reference = Column(String(100), nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    status = Column(String(50), default="MATCHED", nullable=False)  # UNMATCHED, MATCHED, RECONCILIATION_REQUIRED, RECONCILED
    reconciled_at = Column(DateTime, nullable=False)
