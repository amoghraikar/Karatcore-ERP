import random
from datetime import datetime, timezone
from decimal import Decimal
from typing import Optional
from sqlalchemy.orm import Session

from app.core.exceptions import BusinessRuleError, ConflictError, NotFoundError
from app.models.audit import AuditEvent
from app.models.notification import Notification
from app.models.payment import LoanPayment, PaymentRefund, PaymentReversal, Receipt
from app.repositories.loan_repo import LoanRepository
from app.repositories.payment_repo import PaymentRepository
from app.schemas.accounting import JournalEntryCreate, JournalLineCreate
from app.schemas.payment import PaymentCreateRequest, PaymentRefundRequest, PaymentReversalRequest
from app.services.accounting_service import AccountingService


class PaymentService:
    def __init__(self, db: Session):
        self.db = db
        self.loan_repo = LoanRepository(db)
        self.payment_repo = PaymentRepository(db)
        self.accounting_service = AccountingService(db)

    def record_payment(self, req: PaymentCreateRequest, created_by: str = "Owner Counter") -> LoanPayment:
        # Idempotency Check
        if req.idempotency_key:
            existing = self.payment_repo.get_by_idempotency_key(req.idempotency_key)
            if existing:
                return existing

        loan = self.loan_repo.get_by_id(req.loan_id)
        if not loan:
            raise NotFoundError(f"Loan contract #{req.loan_id} does not exist.")

        if loan.status == "CLOSED":
            raise BusinessRuleError("Cannot record payment for a closed loan contract.")

        # Financial Precision & Allocation Validation
        amt = Decimal(str(req.amount)).quantize(Decimal("0.01"))
        p_amt = Decimal(str(req.principal_amount)).quantize(Decimal("0.01"))
        i_amt = Decimal(str(req.interest_amount)).quantize(Decimal("0.01"))
        o_amt = Decimal(str(req.other_amount)).quantize(Decimal("0.01"))

        if amt <= Decimal("0.00"):
            raise BusinessRuleError("Payment amount must be greater than zero.")

        if p_amt + i_amt + o_amt != amt:
            raise BusinessRuleError(f"Allocation total (₹{p_amt + i_amt + o_amt}) does not equal total payment amount (₹{amt}).")

        # ATOMIC FINANCIAL TRANSACTION
        try:
            pay_num = f"PAY-{random.randint(100000, 999999)}"
            rec_num = f"KC-RCP-2026-{random.randint(100000, 999999)}"

            payment = LoanPayment(
                id=pay_num,
                payment_code=pay_num,
                loan_id=loan.id,
                customer_id=loan.customer_id,
                amount=amt,
                principal_amount=p_amt,
                interest_amount=i_amt,
                other_amount=o_amt,
                currency="INR",
                payment_method=req.payment_method,
                payment_source=req.payment_source,
                status="SUCCESS",
                payment_date=datetime.now(timezone.utc),
                reference_number=req.reference_number,
                idempotency_key=req.idempotency_key,
                notes=req.notes or "",
                created_by=created_by,
            )
            self.payment_repo.create_payment(payment)

            # Update Loan Outstanding Balances
            curr_p = Decimal(str(loan.outstanding_principal)).quantize(Decimal("0.01"))
            curr_i = Decimal(str(loan.outstanding_interest)).quantize(Decimal("0.01"))

            new_p = max(Decimal("0.00"), curr_p - p_amt)
            new_i = max(Decimal("0.00"), curr_i - i_amt)

            loan.outstanding_principal = new_p
            loan.outstanding_interest = new_i
            if new_p == Decimal("0.00") and new_i == Decimal("0.00"):
                loan.status = "CLOSED"
            self.loan_repo.update(loan)

            rem_bal = new_p + new_i

            # Deterministic Receipt Generation
            receipt = Receipt(
                receipt_number=rec_num,
                payment_id=payment.id,
                customer_id=loan.customer_id,
                loan_id=loan.id,
                issued_at=datetime.now(timezone.utc),
                total_amount=amt,
                principal_amount=p_amt,
                interest_amount=i_amt,
                remaining_balance=rem_bal,
                currency="INR",
                payment_method=req.payment_method,
                document_reference=f"/receipts/{rec_num}.pdf",
            )
            self.payment_repo.create_receipt(receipt)

            # Post Double-Entry Journal Entry
            je_lines = [
                JournalLineCreate(account_id=1, debit=float(amt), credit=0.0, description=f"Cash payment for Loan #{loan.id}"),
            ]
            if p_amt > Decimal("0.00"):
                je_lines.append(JournalLineCreate(account_id=2, debit=0.0, credit=float(p_amt), description="Principal repayment"))
            if i_amt > Decimal("0.00"):
                je_lines.append(JournalLineCreate(account_id=3, debit=0.0, credit=float(i_amt), description="Interest income"))

            self.accounting_service.post_journal_entry(
                JournalEntryCreate(
                    description=f"Repayment receipt #{rec_num} for Loan #{loan.id}",
                    lines=je_lines,
                    reference_type="LOAN_PAYMENT",
                    reference_id=payment.id,
                )
            )

            # Create Notification
            notif = Notification(
                id=f"NOTIF-{random.randint(10000, 99999)}",
                recipient_type="CUSTOMER",
                recipient_id=loan.customer_id,
                title="Payment Received & Receipt Issued",
                message=f"Received ₹{amt:,.2f} for Loan #{loan.id}. Receipt #{rec_num}. Remaining balance: ₹{rem_bal:,.2f}.",
                category="PAYMENT",
                priority="HIGH",
                status="UNREAD",
            )
            self.db.add(notif)

            # Create Audit Event
            audit = AuditEvent(
                actor_type="OWNER" if req.payment_source == "OWNER_RECORDED" else "CUSTOMER",
                actor_id=created_by,
                action="PAYMENT_RECORDED",
                entity_type="LOAN_PAYMENT",
                entity_id=payment.id,
                metadata_info={"amount": str(amt), "receipt_number": rec_num},
            )
            self.db.add(audit)

            self.db.commit()
            return payment

        except Exception as e:
            self.db.rollback()
            raise e

    def reverse_payment(self, payment_id: str, req: PaymentReversalRequest, actor_name: str) -> PaymentReversal:
        payment = self.payment_repo.get_by_id(payment_id)
        if not payment:
            raise NotFoundError(f"Payment record #{payment_id} not found.")

        if payment.status == "REVERSED":
            raise BusinessRuleError("Payment has already been reversed.")

        amt = Decimal(str(payment.amount)).quantize(Decimal("0.01"))
        p_amt = Decimal(str(payment.principal_amount)).quantize(Decimal("0.01"))
        i_amt = Decimal(str(payment.interest_amount)).quantize(Decimal("0.01"))

        try:
            payment.status = "REVERSED"

            # Restore Loan Balance
            loan = self.loan_repo.get_by_id(payment.loan_id)
            if loan:
                loan.outstanding_principal = Decimal(str(loan.outstanding_principal)) + p_amt
                loan.outstanding_interest = Decimal(str(loan.outstanding_interest)) + i_amt
                if loan.status == "CLOSED":
                    loan.status = "ACTIVE"
                self.loan_repo.update(loan)

            # Create Reversal Record
            reversal = PaymentReversal(
                payment_id=payment.id,
                amount=amt,
                reason=req.reason,
                reference=req.reference,
                created_by=actor_name,
                created_at=datetime.now(timezone.utc),
            )
            self.payment_repo.add_reversal(reversal)

            # Post Reversal Journal Adjustment
            je_lines = [
                JournalLineCreate(account_id=1, debit=0.0, credit=float(amt), description=f"Reversal of Payment #{payment.id}"),
            ]
            if p_amt > Decimal("0.00"):
                je_lines.append(JournalLineCreate(account_id=2, debit=float(p_amt), credit=0.0, description="Restore Loan Principal Asset"))
            if i_amt > Decimal("0.00"):
                je_lines.append(JournalLineCreate(account_id=3, debit=float(i_amt), credit=0.0, description="Reverse Interest Income"))

            self.accounting_service.post_journal_entry(
                JournalEntryCreate(
                    description=f"Reversal of Payment #{payment.id}: {req.reason}",
                    lines=je_lines,
                    reference_type="PAYMENT_REVERSAL",
                    reference_id=payment.id,
                )
            )

            # Audit
            audit = AuditEvent(
                actor_type="OWNER",
                actor_id=actor_name,
                action="PAYMENT_REVERSED",
                entity_type="LOAN_PAYMENT",
                entity_id=payment.id,
                metadata_info={"reason": req.reason, "amount": str(amt)},
            )
            self.db.add(audit)

            self.db.commit()
            return reversal

        except Exception as e:
            self.db.rollback()
            raise e
