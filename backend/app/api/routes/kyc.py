from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.core.exceptions import NotFoundError
from app.models.customer import Customer
from app.models.owner import Owner
from app.schemas.kyc import CustomerKYCSchema, KYCReviewAction, OwnerKYCDboardMetrics
from app.schemas.response import APIResponse
from app.services.kyc_service import KYCService

router = APIRouter(prefix="/kyc", tags=["Owner KYC Management"])


@router.get("/metrics", response_model=APIResponse[OwnerKYCDboardMetrics])
def get_kyc_metrics(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    all_kyc = service.repo.get_all(limit=1000)
    metrics = OwnerKYCDboardMetrics(
        pending_count=sum(1 for k in all_kyc if k.status == "PENDING_CUSTOMER"),
        under_review_count=sum(1 for k in all_kyc if k.status == "UNDER_REVIEW"),
        verified_count=sum(1 for k in all_kyc if k.status == "VERIFIED"),
        rejected_count=sum(1 for k in all_kyc if k.status == "REJECTED"),
        reverification_count=sum(1 for k in all_kyc if k.status == "REVERIFICATION_REQUIRED"),
    )
    return APIResponse(data=metrics)


@router.get("", response_model=APIResponse[List[CustomerKYCSchema]])
def get_kyc_queue(
    status: Optional[str] = None,
    method: Optional[str] = None,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    queue = service.repo.get_all(status=status, method=method)
    return APIResponse(data=[CustomerKYCSchema.model_validate(k) for k in queue])


def _resolve_kyc(service: KYCService, id_str: str):
    if id_str.isdigit():
        k = service.repo.get_by_id(int(id_str))
        if k:
            return k
    return service.repo.get_by_customer_id(id_str)


@router.post("", response_model=APIResponse[dict])
def start_kyc_workflow(
    payload: dict,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    cust_id = payload.get("customer_id", "KC-CUS-000101")
    method = payload.get("method", "MANUAL_STORE_REVIEW")
    kyc = service.get_or_create_kyc(customer_id=cust_id, method=method)

    # When KYC workflow is completed via wizard, set status to VERIFIED
    kyc.status = "VERIFIED"
    kyc.verification_method = method
    kyc.verified_at = datetime.now(timezone.utc)
    kyc.reverification_required = False
    kyc.notes = "Verified via store compliance check."

    # Synchronize Customer table
    customer = db.query(Customer).filter(Customer.id == cust_id).first()
    if customer:
        customer.kyc_status = "VERIFIED"

    db.commit()
    db.refresh(kyc)

    return APIResponse(
        data={
            "id": f"KYC-{kyc.id}",
            "customer_id": cust_id,
            "customer_name": payload.get("customer_name", customer.full_name if customer else "Customer"),
            "customer_mobile": payload.get("customer_mobile", customer.phone if customer else ""),
            "customer_email": payload.get("customer_email", customer.email if customer else ""),
            "status": "verified",
            "method": method,
            "submitted_at": kyc.created_at.isoformat() if kyc.created_at else None,
            "verified_at": kyc.verified_at.isoformat() if kyc.verified_at else None,
        },
        message="KYC workflow completed and verified successfully",
    )


@router.get("/{id}", response_model=APIResponse[CustomerKYCSchema])
def get_kyc_by_id(
    id: str,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    kyc = _resolve_kyc(service, id)
    if not kyc:
        # Create on demand if customer exists
        customer = db.query(Customer).filter(Customer.id == id).first()
        if customer:
            kyc = service.get_or_create_kyc(customer.id)
        else:
            raise NotFoundError("KYC record not found.")
    return APIResponse(data=CustomerKYCSchema.model_validate(kyc))


@router.post("/{id}/approve", response_model=APIResponse[CustomerKYCSchema])
def approve_kyc(
    id: str,
    action: KYCReviewAction,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    kyc = _resolve_kyc(service, id)
    if not kyc:
        raise NotFoundError("KYC record not found.")
    approved = service.approve_kyc(kyc.id, owner.full_name, action)
    return APIResponse(data=CustomerKYCSchema.model_validate(approved), message="KYC record approved successfully")


@router.post("/{id}/reject", response_model=APIResponse[CustomerKYCSchema])
def reject_kyc(
    id: str,
    action: KYCReviewAction,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    kyc = _resolve_kyc(service, id)
    if not kyc:
        raise NotFoundError("KYC record not found.")
    rejected = service.reject_kyc(kyc.id, owner.full_name, action)
    return APIResponse(data=CustomerKYCSchema.model_validate(rejected), message="KYC record rejected")


@router.post("/{id}/reverification", response_model=APIResponse[CustomerKYCSchema])
def request_reverification(
    id: str,
    payload: dict,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    kyc = _resolve_kyc(service, id)
    if not kyc:
        raise NotFoundError("KYC record not found.")
    reason = payload.get("reason", "Identity document update required")
    updated = service.request_reverification(kyc.id, owner.full_name, reason)
    return APIResponse(data=CustomerKYCSchema.model_validate(updated), message="Reverification requested")
