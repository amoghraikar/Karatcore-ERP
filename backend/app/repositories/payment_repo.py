from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.payment import LoanPayment, PaymentReconciliation, PaymentRefund, PaymentReversal, Receipt


class PaymentRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, payment_id: str) -> Optional[LoanPayment]:
        return self.db.query(LoanPayment).filter(LoanPayment.id == payment_id).first()

    def get_by_idempotency_key(self, idempotency_key: str) -> Optional[LoanPayment]:
        return self.db.query(LoanPayment).filter(LoanPayment.idempotency_key == idempotency_key).first()

    def get_receipt_by_payment_id(self, payment_id: str) -> Optional[Receipt]:
        return self.db.query(Receipt).filter(Receipt.payment_id == payment_id).first()

    def get_receipt_by_number(self, receipt_number: str) -> Optional[Receipt]:
        return self.db.query(Receipt).filter(Receipt.receipt_number == receipt_number).first()

    def get_all(
        self,
        loan_id: Optional[str] = None,
        customer_id: Optional[str] = None,
        status: Optional[str] = None,
        method: Optional[str] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[LoanPayment]:
        query = self.db.query(LoanPayment)
        if loan_id:
            query = query.filter(LoanPayment.loan_id == loan_id)
        if customer_id:
            query = query.filter(LoanPayment.customer_id == customer_id)
        if status:
            query = query.filter(LoanPayment.status == status)
        if method:
            query = query.filter(LoanPayment.payment_method == method)
        return query.order_by(LoanPayment.payment_date.desc()).offset(skip).limit(limit).all()

    def create_payment(self, payment: LoanPayment) -> LoanPayment:
        self.db.add(payment)
        return payment

    def create_receipt(self, receipt: Receipt) -> Receipt:
        self.db.add(receipt)
        return receipt

    def add_reversal(self, reversal: PaymentReversal) -> PaymentReversal:
        self.db.add(reversal)
        return reversal

    def add_refund(self, refund: PaymentRefund) -> PaymentRefund:
        self.db.add(refund)
        return refund

    def add_reconciliation(self, recon: PaymentReconciliation) -> PaymentReconciliation:
        self.db.add(recon)
        return recon
