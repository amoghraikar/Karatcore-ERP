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
