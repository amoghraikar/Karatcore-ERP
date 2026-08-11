from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class CustomerKYC(BaseModel):
    __tablename__ = "customer_kyc_records"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(String(50), ForeignKey("customers.id"), nullable=False, unique=True, index=True)
    status = Column(String(50), default="SUBMITTED", nullable=False, index=True)  # SUBMITTED, UNDER_REVIEW, VERIFIED, REJECTED, REVERIFICATION_REQUIRED
    verification_method = Column(String(50), default="MANUAL", nullable=False)  # MANUAL, DIGITAL, PROVIDER
    verified_at = Column(DateTime, nullable=True)
    rejection_reason = Column(String(500), nullable=True)
    reverification_required = Column(Boolean, default=False, nullable=False)
    notes = Column(String(500), default="", nullable=False)

    customer = relationship("Customer", back_populates="kyc_record")
    documents = relationship("KYCDocument", back_populates="kyc_record", cascade="all, delete-orphan")
    consents = relationship("KYCConsent", back_populates="kyc_record", cascade="all, delete-orphan")
    sessions = relationship("KYCVerificationSession", back_populates="kyc_record", cascade="all, delete-orphan")
    history = relationship("KYCVerificationHistory", back_populates="kyc_record", cascade="all, delete-orphan")


class KYCDocument(BaseModel):
    __tablename__ = "kyc_document_metadata"

    id = Column(Integer, primary_key=True, index=True)
    kyc_id = Column(Integer, ForeignKey("customer_kyc_records.id"), nullable=False, index=True)
    document_type = Column(String(50), nullable=False)  # AADHAAR, PAN, PASSPORT, DRIVING_LICENSE, VOTER_ID, OTHER
    masked_identifier = Column(String(100), nullable=False)  # XXXX-XXXX-8821
    storage_reference = Column(String(500), nullable=False)
    file_name = Column(String(255), nullable=False)
    mime_type = Column(String(100), nullable=False)
    file_size = Column(Integer, nullable=False)
    status = Column(String(50), default="SUBMITTED", nullable=False)
    uploaded_at = Column(DateTime, nullable=False)
    verified_at = Column(DateTime, nullable=True)
    rejection_reason = Column(String(500), nullable=True)

    kyc_record = relationship("CustomerKYC", back_populates="documents")


class KYCConsent(BaseModel):
    __tablename__ = "kyc_consents"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(String(50), nullable=False, index=True)
    kyc_id = Column(Integer, ForeignKey("customer_kyc_records.id"), nullable=False, index=True)
    consent_type = Column(String(100), default="IDENTITY_VERIFICATION", nullable=False)
    consent_text_version = Column(String(50), default="KYC_CONSENT_V1", nullable=False)
    consented_at = Column(DateTime, nullable=False)
    consent_status = Column(String(50), default="ACCEPTED", nullable=False)
    consent_reference = Column(String(255), nullable=False)

    kyc_record = relationship("CustomerKYC", back_populates="consents")


class KYCVerificationSession(BaseModel):
    __tablename__ = "kyc_verification_sessions"

    id = Column(String(50), primary_key=True, index=True)
    customer_id = Column(String(50), nullable=False, index=True)
    kyc_id = Column(Integer, ForeignKey("customer_kyc_records.id"), nullable=False, index=True)
    provider = Column(String(50), default="DEMO_MOCK", nullable=False)
    provider_session_id = Column(String(100), nullable=False)
    status = Column(String(50), default="PENDING", nullable=False)  # SESSION_CREATED, PENDING, VERIFIED, FAILED, EXPIRED
    created_at = Column(DateTime, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    completed_at = Column(DateTime, nullable=True)
    failure_reason = Column(String(500), nullable=True)

    kyc_record = relationship("CustomerKYC", back_populates="sessions")


class KYCVerificationHistory(BaseModel):
    __tablename__ = "kyc_verification_history"

    id = Column(Integer, primary_key=True, index=True)
    kyc_id = Column(Integer, ForeignKey("customer_kyc_records.id"), nullable=False, index=True)
    status = Column(String(50), nullable=False)
    action = Column(String(100), nullable=False)  # SUBMITTED, APPROVED, REJECTED, REVERIFICATION_REQUESTED
    actor_type = Column(String(50), nullable=False)  # CUSTOMER, OWNER, SYSTEM
    actor_id = Column(String(50), nullable=False)
    timestamp = Column(DateTime, nullable=False)
    notes = Column(String(500), default="", nullable=False)

    kyc_record = relationship("CustomerKYC", back_populates="history")
