from sqlalchemy import Column, DateTime, String
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Customer(BaseModel):
    __tablename__ = "customers"

    id = Column(String(50), primary_key=True, index=True)  # e.g. KC-CUS-000101
    customer_code = Column(String(50), unique=True, index=True, nullable=False)
    full_name = Column(String(255), nullable=False)
    phone = Column(String(50), index=True, nullable=False)
    email = Column(String(255), index=True, nullable=True)
    address = Column(String(500), nullable=True)
    date_of_birth = Column(DateTime, nullable=True)
    status = Column(String(50), default="ACTIVE", nullable=False)  # ACTIVE, INACTIVE, BLOCKED
    kyc_status = Column(String(50), default="VERIFIED", nullable=False)

    pan_masked = Column(String(50), nullable=True, default="ABCPS****F")
    aadhaar_masked = Column(String(50), nullable=True, default="XXXX-XXXX-8821")

    kyc_record = relationship("CustomerKYC", back_populates="customer", uselist=False)
    ornaments = relationship("Ornament", back_populates="customer")
    pledges = relationship("Pledge", back_populates="customer")
    loans = relationship("Loan", back_populates="customer")
