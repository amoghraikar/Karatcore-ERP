from decimal import Decimal
from typing import Any, Dict, List
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.accounting import JournalEntryLine
from app.models.kyc import CustomerKYC, KYCDocument
from app.models.loan import Loan
from app.models.ornament import Ornament
from app.models.payment import LoanPayment, Receipt


class DiagnosticService:
    def __init__(self, db: Session):
        self.db = db

    def run_system_health_audit(self) -> Dict[str, Any]:
        issues: List[str] = []

        # 1. Double-Entry Accounting Balance Check
        journal_totals = (
            self.db.query(
                JournalEntryLine.journal_entry_id,
                func.sum(JournalEntryLine.debit).label("total_debit"),
                func.sum(JournalEntryLine.credit).label("total_credit"),
            )
            .group_by(JournalEntryLine.journal_entry_id)
            .all()
        )

        unbalanced_entries = [j.journal_entry_id for j in journal_totals if Decimal(str(j.total_debit)) != Decimal(str(j.total_credit))]
        if unbalanced_entries:
            issues.append(f"Unbalanced Journal Entries detected: IDs {unbalanced_entries}")

        # 2. Loan Balance vs Payment Principal Check
        loans = self.db.query(Loan).all()
        for loan in loans:
            payments = self.db.query(LoanPayment).filter(LoanPayment.loan_id == loan.id, LoanPayment.status == "SUCCESS").all()
            total_p_paid = sum(Decimal(str(p.principal_amount)) for p in payments)
            init_p = Decimal(str(loan.principal_amount))
            curr_p = Decimal(str(loan.outstanding_principal))

            if init_p - total_p_paid != curr_p:
                issues.append(f"Mismatch in Loan #{loan.id}: Initial(₹{init_p}) - Paid(₹{total_p_paid}) != Outstanding(₹{curr_p})")

        # 3. Orphan Payment Receipts Check
        payments = self.db.query(LoanPayment).filter(LoanPayment.status == "SUCCESS").all()
        for p in payments:
            receipt = self.db.query(Receipt).filter(Receipt.payment_id == p.id).first()
            if not receipt:
                issues.append(f"Missing receipt for successful Payment #{p.id}")

        # 4. Collateral Single-Pledge Rule Check
        ornaments = self.db.query(Ornament).all()
        for o in ornaments:
            active_pledges_count = self.db.query(Loan).filter(Loan.pledge_id == o.id, Loan.status.in_(["ACTIVE", "DUE_SOON", "OVERDUE"])).count()
            if active_pledges_count > 1:
                issues.append(f"Ornament #{o.id} attached to multiple active loans!")

        return {
            "status": "CLEAN" if not issues else "INTEGRITY_WARNING",
            "issues_found": len(issues),
            "diagnostics": issues or ["All system financial, collateral, and accounting records are 100% balanced."],
        }
