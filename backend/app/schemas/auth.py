from typing import Optional
from pydantic import BaseModel, EmailStr


class LoginRequest(BaseModel):
    username: str  # email or phone
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_type: str
    sub: str
    customer_id: Optional[str] = None


class CustomerAuthRequest(BaseModel):
    customer_id: str
    mobile: str
