from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.exceptions import AuthenticationError
from app.core.security import create_access_token, verify_password
from app.models.customer import Customer
from app.models.owner import Owner
from app.schemas.auth import CustomerAuthRequest, LoginRequest, TokenResponse
from app.schemas.response import APIResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/owner/login", response_model=APIResponse[TokenResponse])
def owner_login(req: LoginRequest, db: Session = Depends(get_db)):
    owner = db.query(Owner).filter(Owner.email == req.username).first()
    if not owner or not verify_password(req.password, owner.password_hash):
        raise AuthenticationError("Invalid email or password for Owner account")

    token = create_access_token(subject=owner.email, user_type="owner")
    return APIResponse(
        data=TokenResponse(access_token=token, user_type="owner", sub=owner.email),
        message="Owner login successful",
    )


@router.post("/customer/login", response_model=APIResponse[TokenResponse])
def customer_login(req: CustomerAuthRequest, db: Session = Depends(get_db)):
    customer = db.query(Customer).filter(Customer.id == req.customer_id).first()
    if not customer or customer.phone != req.mobile:
        raise AuthenticationError("Invalid Customer ID or registered mobile number")

    token = create_access_token(subject=customer.id, user_type="customer", customer_id=customer.id)
    return APIResponse(
        data=TokenResponse(access_token=token, user_type="customer", sub=customer.id, customer_id=customer.id),
        message="Customer portal login successful",
    )
