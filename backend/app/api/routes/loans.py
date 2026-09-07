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


@router.get("/metrics")
def get_loan_metrics(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = LoanService(db)
    loans = service.loan_repo.get_all()
    active_loans = [l for l in loans if getattr(l, "status", "ACTIVE") in ("ACTIVE", "OVERDUE", "DUE_SOON")]
    total_outstanding = sum(getattr(l, "outstanding_principal", 0.0) or 0.0 for l in active_loans)
    total_interest_due = sum(getattr(l, "accrued_interest", 0.0) or 0.0 for l in active_loans)
    overdue_count = sum(1 for l in active_loans if getattr(l, "status", "") == "OVERDUE")
    due_soon_count = sum(1 for l in active_loans if getattr(l, "status", "") == "DUE_SOON")
    closed_count = sum(1 for l in loans if getattr(l, "status", "") in ("CLOSED", "REPAID"))
    total_collateral_value = sum(getattr(l, "collateral_value", 0.0) or 0.0 for l in active_loans)
    total_pledged_weight = sum(getattr(l, "net_weight_grams", 0.0) or 0.0 for l in active_loans)
    total_interest_collected = sum(getattr(l, "interest_collected", 0.0) or 0.0 for l in loans)

    return APIResponse(
        data={
            "active_loans_count": len(active_loans),
            "total_outstanding_principal": total_outstanding,
            "total_interest_due": total_interest_due,
            "total_interest_collected": total_interest_collected,
            "overdue_loans_count": overdue_count,
            "loans_due_soon_count": due_soon_count,
            "loans_closed_this_month_count": closed_count,
            "total_collateral_value": total_collateral_value,
            "total_pledged_weight_grams": total_pledged_weight,
        }
    )


@router.get("/ornaments")
def get_loan_ornaments(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    return APIResponse(data=[])


@router.get("/inventory/metrics")
def get_inventory_metrics(
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = LoanService(db)
    loans = service.loan_repo.get_all()
    active_loans = [l for l in loans if getattr(l, "status", "ACTIVE") in ("ACTIVE", "OVERDUE", "DUE_SOON")]
    total_gross = sum(getattr(l, "gross_weight_grams", 0.0) or 0.0 for l in active_loans)
    total_net = sum(getattr(l, "net_weight_grams", 0.0) or 0.0 for l in active_loans)
    total_val = sum(getattr(l, "collateral_value", 0.0) or 0.0 for l in active_loans)

    return APIResponse(
        data={
            "total_ornaments_count": len(active_loans),
            "total_vault_value": total_val,
            "total_gross_weight_grams": total_gross,
            "total_net_weight_grams": total_net,
            "gold_inventory_weight_grams": total_net,
            "silver_inventory_weight_grams": 0.0,
            "unpledged_stock_count": 0,
            "pledged_vault_count": len(active_loans),
        }
    )


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
