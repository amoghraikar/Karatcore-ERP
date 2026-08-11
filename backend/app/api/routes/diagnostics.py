from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.models.owner import Owner
from app.schemas.response import APIResponse
from app.services.diagnostic_service import DiagnosticService

router = APIRouter(prefix="/diagnostics", tags=["Owner System Diagnostics"])


@router.get("/check", response_model=APIResponse[dict])
def run_system_diagnostics(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = DiagnosticService(db)
    results = service.run_system_health_audit()
    return APIResponse(data=results, message="System health & financial integrity audit complete")
