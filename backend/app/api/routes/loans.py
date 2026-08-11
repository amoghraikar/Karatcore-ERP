from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.core.exceptions import NotFoundError
from app.models.owner import Owner
from app.schemas.loan import LoanCreate, LoanResponse
from app.schemas.response import APIResponse
from app.services.loan_service import LoanService

router = APIRouter(prefix="/loans", tags=["Loans"])


@router.get("", response_model=APIResponse[List[LoanResponse]])
def get_loans(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = LoanService(db)
    loans = service.loan_repo.get_all()
    return APIResponse(data=[LoanResponse.model_validate(l) for l in loans])


@router.post("", response_model=APIResponse[LoanResponse])
def create_loan(
    req: LoanCreate,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = LoanService(db)
    loan = service.create_loan(req)
    return APIResponse(data=LoanResponse.model_validate(loan), message="Pledge loan created & disbursed")


@router.get("/{id}", response_model=APIResponse[LoanResponse])
def get_loan_by_id(
    id: str,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = LoanService(db)
    loan = service.loan_repo.get_by_id(id)
    if not loan:
        raise NotFoundError(f"Loan contract #{id} not found.")
    return APIResponse(data=LoanResponse.model_validate(loan))
