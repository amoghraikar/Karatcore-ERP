from sqlalchemy import Boolean, Column, DateTime, Integer, String
from app.models.base import BaseModel


class Notification(BaseModel):
    __tablename__ = "notifications"

    id = Column(String(50), primary_key=True, index=True)
    recipient_type = Column(String(50), nullable=False)  # OWNER, CUSTOMER
    recipient_id = Column(String(50), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    message = Column(String(1000), nullable=False)
    category = Column(String(100), nullable=False)  # DUE_DATE, PAYMENT, KYC, ALERT
    priority = Column(String(50), default="MEDIUM", nullable=False)
    status = Column(String(50), default="UNREAD", nullable=False, index=True)  # UNREAD, READ, ARCHIVED
    related_entity_type = Column(String(50), nullable=True)
    related_entity_id = Column(String(50), nullable=True)
    read_at = Column(DateTime, nullable=True)
    archived_at = Column(DateTime, nullable=True)


class NotificationPreference(BaseModel):
    __tablename__ = "notification_preferences"

    id = Column(Integer, primary_key=True, index=True)
    recipient_type = Column(String(50), nullable=False)  # OWNER, CUSTOMER
    recipient_id = Column(String(50), nullable=False, index=True)
    category = Column(String(100), nullable=False)
    in_app_enabled = Column(Boolean, default=True, nullable=False)
    email_enabled = Column(Boolean, default=False, nullable=False)
    sms_enabled = Column(Boolean, default=True, nullable=False)
    whatsapp_enabled = Column(Boolean, default=True, nullable=False)
    push_enabled = Column(Boolean, default=False, nullable=False)
