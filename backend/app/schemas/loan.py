from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict


class LoanCreate(BaseModel):
    customer_id: str
    principal_amount: float
    interest_rate: float
    pledge_id: Optional[str] = None


class LoanPaymentCreate(BaseModel):
    loan_id: str
    amount: float
    principal_amount: float
    interest_amount: float
    payment_method: str  # UPI, CASH, BANK_TRANSFER


class LoanPaymentResponse(BaseModel):
    id: str
    payment_code: str
    loan_id: str
    amount: float
    principal_amount: float
    interest_amount: float
    payment_method: str
    payment_date: datetime
    status: str

    model_config = ConfigDict(from_attributes=True)


class LoanResponse(BaseModel):
    id: str
    loan_code: str
    customer_id: str
    principal_amount: float
    interest_rate: float
    start_date: datetime
    maturity_date: datetime
    next_due_date: datetime
    status: str
    outstanding_principal: float
    outstanding_interest: float

    model_config = ConfigDict(from_attributes=True)
