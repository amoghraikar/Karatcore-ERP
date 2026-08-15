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
            "total_income": 350000.0,
            "total_expenses": 120000.0,
            "net_profit": 230000.0,
            "cash_on_hand": 850000.0,
            "bank_balance": 1250000.0,
            "interest_income": 280000.0,
        }
    )


@router.get("/accounts")
def get_accounts(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    return APIResponse(
        data=[
            {"id": "1", "account_number": "1001", "name": "Cash Desk Vault", "account_type": "ASSET", "balance": 850000.0},
            {"id": "2", "account_number": "1002", "name": "Primary HDFC Bank", "account_type": "ASSET", "balance": 1250000.0},
            {"id": "3", "account_number": "4001", "name": "Gold Loan Interest Revenue", "account_type": "INCOME", "balance": 280000.0},
            {"id": "4", "account_number": "5001", "name": "Store Rent & Utilities", "account_type": "EXPENSE", "balance": 45000.0},
        ]
    )


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
