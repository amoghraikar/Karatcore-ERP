from sqlalchemy import Column, Integer, JSON, String
from app.models.base import BaseModel


class AuditEvent(BaseModel):
    __tablename__ = "audit_events"

    id = Column(Integer, primary_key=True, index=True)
    actor_type = Column(String(50), nullable=False)  # OWNER, CUSTOMER, SYSTEM
    actor_id = Column(String(50), nullable=False)
    action = Column(String(100), nullable=False)  # CUSTOMER_CREATED, LOAN_DISBURSED, PAYMENT_RECORDED
    entity_type = Column(String(100), nullable=False)
    entity_id = Column(String(100), nullable=False, index=True)
    old_values = Column(JSON, nullable=True)
    new_values = Column(JSON, nullable=True)
    metadata_info = Column(JSON, nullable=True)
    ip_address = Column(String(100), nullable=True)
    user_agent = Column(String(255), nullable=True)


class SecurityEvent(BaseModel):
    __tablename__ = "security_events"

    id = Column(Integer, primary_key=True, index=True)
    actor_type = Column(String(50), nullable=False)
    actor_id = Column(String(50), nullable=False)
    event_type = Column(String(100), nullable=False)  # LOGIN_SUCCESS, LOGIN_FAILURE, ACCESS_RESTRICTED
    ip_address = Column(String(100), nullable=True)
    user_agent = Column(String(255), nullable=True)
    metadata_info = Column(JSON, nullable=True)
