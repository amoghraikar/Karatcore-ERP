from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_customer
from app.core.database import get_db
from app.models.customer import Customer
from app.schemas.kyc import CustomerKYCSchema, KYCConsentRequest, KYCConsentResponse, KYCDocumentResponse, KYCDocumentUploadRequest
from app.schemas.response import APIResponse
from app.services.kyc_service import KYCService

router = APIRouter(prefix="/customer/kyc", tags=["Customer KYC Portal"])


@router.post("/start", response_model=APIResponse[CustomerKYCSchema])
def start_kyc(
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = KYCService(db)
    kyc = service.get_or_create_kyc(customer.id)
    return APIResponse(data=CustomerKYCSchema.model_validate(kyc), message="KYC workflow initialized")


@router.get("", response_model=APIResponse[CustomerKYCSchema])
def get_my_kyc(
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = KYCService(db)
    kyc = service.get_or_create_kyc(customer.id)
    return APIResponse(data=CustomerKYCSchema.model_validate(kyc))


@router.post("/documents", response_model=APIResponse[KYCDocumentResponse])
def upload_kyc_document(
    req: KYCDocumentUploadRequest,
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = KYCService(db)
    doc = service.upload_document(customer.id, req)
    return APIResponse(data=KYCDocumentResponse.model_validate(doc), message="KYC document uploaded successfully")


@router.delete("/documents/{doc_id}", response_model=APIResponse[dict])
def delete_kyc_document(
    doc_id: int,
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = KYCService(db)
    service.delete_document(customer.id, doc_id)
    return APIResponse(data={"success": True}, message="Document removed from KYC queue")


@router.post("/consent", response_model=APIResponse[KYCConsentResponse])
def record_kyc_consent(
    req: KYCConsentRequest,
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = KYCService(db)
    consent = service.record_consent(customer.id, req)
    return APIResponse(data=KYCConsentResponse.model_validate(consent), message="Versioned KYC consent recorded")


@router.post("/submit", response_model=APIResponse[CustomerKYCSchema])
def submit_kyc(
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = KYCService(db)
    kyc = service.submit_kyc(customer.id)
    return APIResponse(data=CustomerKYCSchema.model_validate(kyc), message="KYC record submitted for Store Owner review")


@router.post("/digital-verification", response_model=APIResponse[dict])
def start_digital_verification(
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    service = KYCService(db)
    session = service.create_digital_verification_session(customer.id)
    return APIResponse(
        data={
            "session_id": session.id,
            "status": session.status,
            "provider": session.provider,
            "disclaimer": "DEMO / SIMULATED VERIFICATION SESSION",
        },
        message="Simulated digital verification session created",
    )
