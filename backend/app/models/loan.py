from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Loan(BaseModel):
    __tablename__ = "loans"

    id = Column(String(50), primary_key=True, index=True)  # e.g. KC-LN-9042
    loan_code = Column(String(50), unique=True, index=True, nullable=False)
    customer_id = Column(String(50), ForeignKey("customers.id"), nullable=False, index=True)
    pledge_id = Column(String(50), nullable=True)

    # Financial Precision using Numeric(12, 2)
    principal_amount = Column(Numeric(12, 2), nullable=False)
    interest_rate = Column(Numeric(5, 2), nullable=False)  # % per annum
    interest_type = Column(String(50), default="SIMPLE", nullable=False)
    start_date = Column(DateTime, nullable=False)
    maturity_date = Column(DateTime, nullable=False, index=True)
    next_due_date = Column(DateTime, nullable=False, index=True)
    status = Column(String(50), default="ACTIVE", nullable=False, index=True)  # DRAFT, ACTIVE, DUE_SOON, OVERDUE, CLOSED

    outstanding_principal = Column(Numeric(12, 2), nullable=False)
    outstanding_interest = Column(Numeric(12, 2), default=0.00, nullable=False)

    customer = relationship("Customer", back_populates="loans")
    payments = relationship("LoanPayment", back_populates="loan")
