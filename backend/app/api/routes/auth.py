import uuid
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.exceptions import AuthenticationError, BusinessRuleError
from app.core.security import create_access_token, hash_password, verify_password
from app.models.customer import Customer
from app.models.owner import Owner
from app.schemas.auth import CustomerAuthRequest, LoginRequest, OwnerRegisterRequest, TokenResponse
from app.schemas.response import APIResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])


def normalize_phone(phone_str: str) -> str:
    if not phone_str:
        return ""
    digits = "".join(c for c in str(phone_str) if c.isdigit())
    if len(digits) == 12 and digits.startswith("91"):
        return digits[2:]
    if len(digits) == 11 and digits.startswith("0"):
        return digits[1:]
    return digits


@router.post("/owner/register", response_model=APIResponse[TokenResponse])
def owner_register(req: OwnerRegisterRequest, db: Session = Depends(get_db)):
    norm_phone = normalize_phone(req.phone)
    owners = db.query(Owner).all()

    for candidate in owners:
        if candidate.email.strip().lower() == req.email.strip().lower():
            raise BusinessRuleError("An Owner account with this email address already exists.")
        if candidate.phone and (candidate.phone.strip() == req.phone.strip() or (norm_phone and normalize_phone(candidate.phone) == norm_phone)):
            raise BusinessRuleError("An Owner account with this mobile number already exists.")

    new_owner = Owner(
        full_name=req.full_name,
        store_name=req.business_name.strip() if req.business_name else None,
        email=req.email,
        phone=req.phone,
        password_hash=hash_password(req.password),
        status="ACTIVE",
    )
    db.add(new_owner)
    db.commit()
    db.refresh(new_owner)

    token = create_access_token(subject=new_owner.email, user_type="owner")
    return APIResponse(
        data=TokenResponse(
            access_token=token,
            user_type="owner",
            sub=new_owner.email,
            full_name=new_owner.full_name,
            store_name=new_owner.store_name,
            phone=new_owner.phone,
        ),
        message="Store Owner account successfully registered!",
    )


@router.post("/owner/login", response_model=APIResponse[TokenResponse])
def owner_login(req: LoginRequest, db: Session = Depends(get_db)):
    username_input = req.username.strip()
    norm_input = normalize_phone(username_input)

    owners = db.query(Owner).all()
    owner = None

    for candidate in owners:
        if candidate.email.strip().lower() == username_input.lower():
            owner = candidate
            break
        if candidate.phone and (candidate.phone.strip() == username_input or (norm_input and normalize_phone(candidate.phone) == norm_input)):
            owner = candidate
            break

    if not owner or not verify_password(req.password, owner.password_hash):
        raise AuthenticationError("Invalid email/phone or password for Owner account")

    token = create_access_token(subject=owner.email, user_type="owner")
    return APIResponse(
        data=TokenResponse(
            access_token=token,
            user_type="owner",
            sub=owner.email,
            full_name=owner.full_name,
            store_name=owner.store_name,
            phone=owner.phone,
        ),
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
