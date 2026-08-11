from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.models.owner import Owner
from app.schemas.accounting import JournalEntryCreate, JournalEntryResponse
from app.schemas.response import APIResponse
from app.services.accounting_service import AccountingService

router = APIRouter(prefix="/accounting", tags=["Accounting"])


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
