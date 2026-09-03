from typing import Optional
from pydantic import BaseModel, EmailStr


class LoginRequest(BaseModel):
    username: str  # email or phone
    password: str


class OwnerRegisterRequest(BaseModel):
    full_name: str
    business_name: str
    phone: str
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_type: str
    sub: str
    full_name: Optional[str] = None
    store_name: Optional[str] = None
    phone: Optional[str] = None
    customer_id: Optional[str] = None


class CustomerAuthRequest(BaseModel):
    customer_id: str
    mobile: str


class TwoFactorSetupResponse(BaseModel):
    secret: str
    qr_uri: str
    backup_codes: list[str]


class TwoFactorVerifyRequest(BaseModel):
    code: str
    secret: Optional[str] = None

