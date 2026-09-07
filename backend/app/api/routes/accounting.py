from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.models.owner import Owner
from app.schemas.accounting import JournalEntryCreate, JournalEntryResponse
from app.schemas.response import APIResponse
from app.services.accounting_service import AccountingService

router = APIRouter(prefix="/accounting", tags=["Accounting"])


@router.get("/metrics")
def get_accounting_metrics(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    return APIResponse(
        data={
            "total_income": 0.0,
            "total_expenses": 0.0,
            "net_profit": 0.0,
            "cash_on_hand": 0.0,
            "bank_balance": 0.0,
            "interest_income": 0.0,
        }
    )


@router.get("/accounts")
def get_accounts(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    return APIResponse(data=[])


@router.get("/transactions/periods")
def get_transaction_periods(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    return APIResponse(data=["2026-08", "2026-07", "2026-06", "2026-05"])


@router.post("/journal-entries", response_model=APIResponse[JournalEntryResponse])
def post_journal_entry(
    req: JournalEntryCreate,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = AccountingService(db)
    posted = service.post_journal_entry(req)
    db.commit()
    return APIResponse(data=JournalEntryResponse.model_validate(posted), message="Balanced double-entry journal posted successfully")
