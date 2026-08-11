from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, EmailStr


class CustomerBase(BaseModel):
    full_name: str
    phone: str
    email: Optional[EmailStr] = None
    address: Optional[str] = None


class CustomerCreate(CustomerBase):
    customer_code: Optional[str] = None


class CustomerResponse(CustomerBase):
    id: str
    customer_code: str
    status: str
    kyc_status: str
    pan_masked: Optional[str] = None
    aadhaar_masked: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class CustomerKYCResponse(BaseModel):
    id: int
    customer_id: str
    status: str
    verification_method: str
    verified_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
