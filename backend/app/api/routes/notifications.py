from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.models.owner import Owner
from app.schemas.response import APIResponse

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("")
def get_notifications(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    return APIResponse(
        data=[
            {
                "id": "notif-1",
                "title": "System Audit Complete",
                "message": "Vault reconciliation and ledger audit verified with zero discrepancies.",
                "type": "SYSTEM",
                "read": False,
                "created_at": "2026-08-16T02:00:00Z",
            },
            {
                "id": "notif-2",
                "title": "Loan Interest Due Reminder",
                "message": "2 loan receipts are due for monthly interest collection today.",
                "type": "REMINDER",
                "read": False,
                "created_at": "2026-08-16T01:30:00Z",
            },
        ]
    )
