from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.loan import Loan
from app.models.payment import LoanPayment


class LoanRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, loan_id: str) -> Optional[Loan]:
        return self.db.query(Loan).filter(Loan.id == loan_id).first()

    def get_by_customer_id(self, customer_id: str) -> List[Loan]:
        return self.db.query(Loan).filter(Loan.customer_id == customer_id).all()

    def get_all(self, skip: int = 0, limit: int = 100) -> List[Loan]:
        return self.db.query(Loan).offset(skip).limit(limit).all()

    def create(self, loan: Loan) -> Loan:
        self.db.add(loan)
        self.db.commit()
        self.db.refresh(loan)
        return loan

    def update(self, loan: Loan) -> Loan:
        self.db.commit()
        self.db.refresh(loan)
        return loan
