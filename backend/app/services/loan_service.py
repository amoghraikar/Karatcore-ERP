import random
from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from app.core.exceptions import BusinessRuleError, NotFoundError
from app.models.loan import Loan
from app.repositories.customer_repo import CustomerRepository
from app.repositories.loan_repo import LoanRepository
from app.schemas.loan import LoanCreate


class LoanService:
    def __init__(self, db: Session):
        self.db = db
        self.loan_repo = LoanRepository(db)
        self.customer_repo = CustomerRepository(db)

    def create_loan(self, loan_in: LoanCreate) -> Loan:
        customer = self.customer_repo.get_by_id(loan_in.customer_id)
        if not customer:
            raise NotFoundError(f"Customer with ID #{loan_in.customer_id} does not exist.")

        if loan_in.principal_amount <= 0:
            raise BusinessRuleError("Principal amount must be greater than zero.")

        loan_id = f"KC-LN-{random.randint(8000, 9999)}"
        now = datetime.now(timezone.utc)
        maturity = now + timedelta(days=365)
        next_due = now + timedelta(days=30)

        loan = Loan(
            id=loan_id,
            loan_code=loan_id,
            customer_id=customer.id,
            pledge_id=loan_in.pledge_id,
            principal_amount=loan_in.principal_amount,
            interest_rate=loan_in.interest_rate,
            interest_type="SIMPLE",
            start_date=now,
            maturity_date=maturity,
            next_due_date=next_due,
            status="ACTIVE",
            outstanding_principal=loan_in.principal_amount,
            outstanding_interest=0.0,
        )

        return self.loan_repo.create(loan)
