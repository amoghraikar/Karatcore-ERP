from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict


class KYCDocumentUploadRequest(BaseModel):
    document_type: str  # AADHAAR, PAN, PASSPORT, DRIVING_LICENSE, VOTER_ID, OTHER
    masked_identifier: str  # e.g., XXXX-XXXX-8821 or ABCPS****F
    file_name: str
    mime_type: str
    file_size: int


class KYCDocumentResponse(BaseModel):
    id: int
    kyc_id: int
    document_type: str
    masked_identifier: str
    storage_reference: str
    file_name: str
    mime_type: str
    file_size: int
    status: str
    uploaded_at: datetime
    verified_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class KYCConsentRequest(BaseModel):
    consent_type: str = "IDENTITY_VERIFICATION"
    consent_text_version: str = "KYC_CONSENT_V1"


class KYCConsentResponse(BaseModel):
    id: int
    customer_id: str
    consent_type: str
    consent_text_version: str
    consented_at: datetime
    consent_status: str

    model_config = ConfigDict(from_attributes=True)


class KYCReviewAction(BaseModel):
    reviewer_notes: str
    rejection_reason: Optional[str] = None


class CustomerKYCSchema(BaseModel):
    id: int
    customer_id: str
    status: str
    verification_method: str
    verified_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None
    reverification_required: bool
    documents: List[KYCDocumentResponse] = []
    consents: List[KYCConsentResponse] = []

    model_config = ConfigDict(from_attributes=True)


class OwnerKYCDboardMetrics(BaseModel):
    pending_count: int
    under_review_count: int
    verified_count: int
    rejected_count: int
    reverification_count: int
