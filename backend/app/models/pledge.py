from sqlalchemy import Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Pledge(BaseModel):
    __tablename__ = "pledges"

    id = Column(String(50), primary_key=True, index=True)  # e.g. PLG-9042
    pledge_code = Column(String(50), unique=True, index=True, nullable=False)
    customer_id = Column(String(50), ForeignKey("customers.id"), nullable=False, index=True)
    loan_id = Column(String(50), nullable=True, index=True)
    pledge_date = Column(DateTime, nullable=False)
    status = Column(String(50), default="ACTIVE", nullable=False)  # ACTIVE, RELEASED
    notes = Column(String(500), default="", nullable=False)

    customer = relationship("Customer", back_populates="pledges")
