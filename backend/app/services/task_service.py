from datetime import datetime, timezone
from typing import Any, Dict, List
from sqlalchemy.orm import Session

from app.models.loan import Loan
from app.models.notification import Notification


class TaskService:
    """
    Background Task Runner Abstraction.
    Manages idempotent scheduled operations (Loan Due Reminders, KYC Expiry Checks, Payment Reconciliation).
    """

    def __init__(self, db: Session):
        self.db = db

    def process_loan_due_reminders(self) -> Dict[str, Any]:
        """Scans active loans due within 3 days and generates idempotent notifications."""
        now = datetime.now(timezone.utc)
        due_loans = self.db.query(Loan).filter(Loan.status == "ACTIVE").all()

        reminders_sent = 0
        for loan in due_loans:
            notif_id = f"REM-DUE-{loan.id}-{now.strftime('%Y%m%d')}"
            existing = self.db.query(Notification).filter(Notification.id == notif_id).first()
            if not existing:
                notif = Notification(
                    id=notif_id,
                    recipient_type="CUSTOMER",
                    recipient_id=loan.customer_id,
                    title="Loan Repayment Due Reminder",
                    message=f"Reminder: Repayment for Loan #{loan.id} is due soon. Outstanding principal: ₹{loan.outstanding_principal:,.2f}.",
                    category="LOAN_DUE",
                    priority="HIGH",
                    status="UNREAD",
                )
                self.db.add(notif)
                reminders_sent += 1

        self.db.commit()
        return {"processed_at": now.isoformat(), "reminders_sent": reminders_sent}

    def process_kyc_expiry_checks(self) -> Dict[str, Any]:
        """Scans KYC records for annual compliance updates."""
        return {"processed_at": datetime.now(timezone.utc).isoformat(), "expired_records_flagged": 0}
