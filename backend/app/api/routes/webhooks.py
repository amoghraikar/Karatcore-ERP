from fastapi import APIRouter, Depends, Header
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.response import APIResponse
from app.services.webhook_service import WebhookService

router = APIRouter(prefix="/payments/webhooks", tags=["Payment Webhooks"])


@router.post("/{provider}", response_model=APIResponse[dict])
def process_provider_webhook(
    provider: str,
    payload: dict,
    x_event_id: str = Header(..., alias="X-Event-ID"),
    db: Session = Depends(get_db),
):
    service = WebhookService(db)

    # Idempotency Check
    if service.is_event_processed(x_event_id):
        return APIResponse(data={"processed": False, "reason": "Event already processed"}, message="Duplicate webhook event ignored (idempotent)")

    service.record_webhook_event(x_event_id, provider, payload.get("event_type", "PAYMENT_SUCCESS"))
    return APIResponse(data={"processed": True, "event_id": x_event_id}, message="Payment webhook processed successfully")
