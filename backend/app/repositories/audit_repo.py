from sqlalchemy.orm import Session
from app.models.audit import AuditEvent, SecurityEvent


class AuditRepository:
    def __init__(self, db: Session):
        self.db = db

    def log_audit_event(self, event: AuditEvent) -> AuditEvent:
        self.db.add(event)
        return event

    def log_security_event(self, event: SecurityEvent) -> SecurityEvent:
        self.db.add(event)
        return event
