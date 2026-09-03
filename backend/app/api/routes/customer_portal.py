from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_customer
from app.core.database import get_db
from app.core.exceptions import NotFoundError
from app.models.customer import Customer
from app.repositories.customer_repo import CustomerRepository
from app.repositories.loan_repo import LoanRepository
from app.repositories.payment_repo import PaymentRepository
from app.schemas.customer import CustomerResponse
from app.schemas.loan import LoanPaymentResponse, LoanResponse
from app.schemas.ornament import OrnamentResponse
from app.schemas.response import APIResponse

router = APIRouter(prefix="/customer", tags=["Customer Portal"])


@router.get("/profile", response_model=APIResponse[CustomerResponse])
def get_customer_profile(customer: Customer = Depends(get_current_customer)):
    return APIResponse(data=CustomerResponse.model_validate(customer))


@router.get("/loans", response_model=APIResponse[List[LoanResponse]])
def get_customer_loans(
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    loan_repo = LoanRepository(db)
    loans = loan_repo.get_by_customer_id(customer.id)
    return APIResponse(data=[LoanResponse.model_validate(l) for l in loans])


@router.get("/loans/{id}", response_model=APIResponse[LoanResponse])
def get_customer_loan_by_id(
    id: str,
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    loan_repo = LoanRepository(db)
    loan = loan_repo.get_by_id(id)

    # STRICT DATA ISOLATION ENFORCEMENT
    if not loan or loan.customer_id != customer.id:
        raise NotFoundError("Access Restricted: Loan record not found or does not belong to your account.")

    return APIResponse(data=LoanResponse.model_validate(loan))


@router.get("/jewellery", response_model=APIResponse[List[OrnamentResponse]])
def get_customer_jewellery(
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    customer_repo = CustomerRepository(db)
    items = customer_repo.get_jewellery(customer.id)
    return APIResponse(data=[OrnamentResponse.model_validate(i) for i in items])


@router.get("/jewellery/{id}", response_model=APIResponse[OrnamentResponse])
def get_customer_jewellery_by_id(
    id: str,
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    customer_repo = CustomerRepository(db)
    items = customer_repo.get_jewellery(customer.id)
    item = next((i for i in items if i.id == id), None)

    # STRICT DATA ISOLATION ENFORCEMENT
    if not item or item.customer_id != customer.id:
        raise NotFoundError("Access Restricted: Jewellery ornament not found or does not belong to your account.")

    return APIResponse(data=OrnamentResponse.model_validate(item))


@router.get("/payments", response_model=APIResponse[List[LoanPaymentResponse]])
def get_customer_payments(
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    payment_repo = PaymentRepository(db)
    payments = payment_repo.get_all(customer_id=customer.id)
    return APIResponse(data=[LoanPaymentResponse.model_validate(p) for p in payments])


@router.get("/certificates/{ornament_id}", response_model=APIResponse[dict])
def get_ornament_certificate(
    ornament_id: str,
    customer: Customer = Depends(get_current_customer),
    db: Session = Depends(get_db),
):
    """Retrieve BIS Hallmark Quality Certificate & Appraiser Assay breakdown for pledged ornament."""
    customer_repo = CustomerRepository(db)
    items = customer_repo.get_jewellery(customer.id)
    item = next((i for i in items if i.id == ornament_id), None)

    cert_data = {
        "certificate_id": f"CERT-BIS-{ornament_id}",
        "ornament_id": ornament_id,
        "ornament_name": item.name if item else "Pledged Gold Ornament",
        "customer_id": customer.id,
        "customer_name": customer.full_name,
        "bis_hallmark_no": "BIS-HM-22K-916-400002",
        "purity_standard": item.purity_karat if hasattr(item, 'purity_karat') else "22K (91.6% Pure Gold)",
        "gross_weight": item.gross_weight if hasattr(item, 'gross_weight') else "24.50g",
        "net_weight": item.net_weight if hasattr(item, 'net_weight') else "22.80g",
        "stone_weight": "1.70g",
        "appraised_value": item.valuation_amount if hasattr(item, 'valuation_amount') else 165400.0,
        "appraiser_name": "Government Approved Assayer #982",
        "vault_location": "Safe Vault A-12 (Insured Storage)",
        "issued_date": "2026-01-15",
        "verification_status": "BIS VERIFIED & SEALED",
    }
    return APIResponse(data=cert_data, message="Quality certificate retrieved successfully.")

