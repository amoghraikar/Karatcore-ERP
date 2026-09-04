from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.core.exceptions import NotFoundError
from app.models.owner import Owner
from app.schemas.customer import CustomerCreate, CustomerResponse
from app.schemas.response import APIResponse
from app.services.customer_service import CustomerService

router = APIRouter(prefix="/customers", tags=["Customers"])


@router.get("", response_model=APIResponse[List[CustomerResponse]])
def get_customers(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = CustomerService(db)
    customers = service.repo.get_all()
    return APIResponse(data=[CustomerResponse.model_validate(c) for c in customers])


@router.post("", response_model=APIResponse[CustomerResponse])
def create_customer(
    req: CustomerCreate,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = CustomerService(db)
    customer = service.create_customer(req)
    return APIResponse(data=CustomerResponse.model_validate(customer), message="Customer registered successfully")


@router.get("/{id}", response_model=APIResponse[CustomerResponse])
def get_customer_by_id(
    id: str,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = CustomerService(db)
    customer = service.repo.get_by_id(id)
    if not customer:
        raise NotFoundError(f"Customer #{id} not found.")
    return APIResponse(data=CustomerResponse.model_validate(customer))


@router.post("/{id}/kyc-status", response_model=APIResponse[CustomerResponse])
def update_customer_kyc_status(
    id: str,
    payload: dict,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    from datetime import datetime, timezone
    from app.models.kyc import CustomerKYC

    service = CustomerService(db)
    customer = service.repo.get_by_id(id)
    if not customer:
        raise NotFoundError(f"Customer #{id} not found.")

    status_str = payload.get("kyc_status", "VERIFIED").upper()
    customer.kyc_status = status_str

    # Synchronize CustomerKYC model in DB
    kyc = db.query(CustomerKYC).filter(CustomerKYC.customer_id == customer.id).first()
    if not kyc:
        kyc = CustomerKYC(
            customer_id=customer.id,
            status=status_str,
            verification_method="MANUAL_STORE_REVIEW",
            verified_at=datetime.now(timezone.utc) if status_str == "VERIFIED" else None,
        )
        db.add(kyc)
    else:
        kyc.status = status_str
        if status_str == "VERIFIED":
            kyc.verified_at = datetime.now(timezone.utc)
            kyc.reverification_required = False

    db.commit()
    db.refresh(customer)
    return APIResponse(data=CustomerResponse.model_validate(customer), message="Customer KYC status updated successfully")
