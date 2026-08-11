from datetime import datetime, timezone
from sqlalchemy.orm import Session
from app.models.payment import PaymentWebhookEvent


class WebhookService:
    def __init__(self, db: Session):
        self.db = db

    def is_event_processed(self, event_id: str) -> bool:
        existing = self.db.query(PaymentWebhookEvent).filter(PaymentWebhookEvent.event_id == event_id).first()
        return existing is not None

    def record_webhook_event(self, event_id: str, provider: str, event_type: str) -> PaymentWebhookEvent:
        evt = PaymentWebhookEvent(
            event_id=event_id,
            provider=provider,
            event_type=event_type,
            processed=datetime.now(timezone.utc),
        )
        self.db.add(evt)
        self.db.commit()
        return evt
