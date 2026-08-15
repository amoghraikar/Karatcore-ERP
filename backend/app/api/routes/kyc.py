from typing import List, Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.core.exceptions import NotFoundError
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

    return APIResponse(
        data={
            "id": f"KYC-{kyc.id}",
            "customer_id": cust_id,
            "customer_name": payload.get("customer_name", "Customer"),
            "customer_mobile": payload.get("customer_mobile", ""),
            "customer_email": payload.get("customer_email", ""),
            "status": "verified",
            "method": method,
            "submitted_at": kyc.created_at.isoformat() if kyc.created_at else None,
            "verified_at": kyc.verified_at.isoformat() if kyc.verified_at else None,
        },
        message="KYC workflow initiated successfully",
    )


@router.get("/{id}", response_model=APIResponse[CustomerKYCSchema])
def get_kyc_by_id(
    id: int,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    kyc = service.repo.get_by_id(id)
    if not kyc:
        raise NotFoundError("KYC record not found.")
    return APIResponse(data=CustomerKYCSchema.model_validate(kyc))


@router.post("/{id}/approve", response_model=APIResponse[CustomerKYCSchema])
def approve_kyc(
    id: int,
    action: KYCReviewAction,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    approved = service.approve_kyc(id, owner.full_name, action)
    return APIResponse(data=CustomerKYCSchema.model_validate(approved), message="KYC record approved successfully")


@router.post("/{id}/reject", response_model=APIResponse[CustomerKYCSchema])
def reject_kyc(
    id: int,
    action: KYCReviewAction,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    rejected = service.reject_kyc(id, owner.full_name, action)
    return APIResponse(data=CustomerKYCSchema.model_validate(rejected), message="KYC record rejected")


@router.post("/{id}/reverification", response_model=APIResponse[CustomerKYCSchema])
def request_reverification(
    id: int,
    action: KYCReviewAction,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = KYCService(db)
    rever = service.request_reverification(id, owner.full_name, action)
    return APIResponse(data=CustomerKYCSchema.model_validate(rever), message="Reverification requested from customer")
