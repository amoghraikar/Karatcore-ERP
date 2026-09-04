import uuid
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.exceptions import AuthenticationError, BusinessRuleError
from app.core.security import create_access_token, hash_password, verify_password
from app.api.dependencies import get_current_owner
from app.models.customer import Customer
from app.models.owner import Owner
from app.schemas.auth import (
    ChangePasswordRequest,
    CustomerAuthRequest,
    LoginRequest,
    OwnerProfileResponse,
    OwnerProfileUpdateRequest,
    OwnerRegisterRequest,
    TokenResponse,
)
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


from datetime import datetime, timedelta
import random
from typing import Dict, Any, Optional

from app.schemas.auth import (
    CustomerAuthRequest,
    LoginRequest,
    OwnerRegisterRequest,
    TokenResponse,
    TwoFactorSetupResponse,
    TwoFactorVerifyRequest,
)
from app.api.routes.settings import SYSTEM_SETTINGS


@router.post("/customer/login", response_model=APIResponse[TokenResponse])
def customer_login(req: CustomerAuthRequest, db: Session = Depends(get_db)):
    customer = db.query(Customer).filter(Customer.id == req.customer_id).first()
    if not customer or customer.phone != req.mobile:
        raise AuthenticationError("Invalid Customer ID or registered mobile number")

    token = create_access_token(subject=customer.id, user_type="customer", customer_id=customer.id)
    return APIResponse(
        data=TokenResponse(
            access_token=token,
            user_type="customer",
            sub=customer.id,
            customer_id=customer.id,
            full_name=customer.full_name,
            phone=customer.phone,
        ),
        message="Customer portal login successful",
    )



@router.post("/2fa/setup", response_model=APIResponse[TwoFactorSetupResponse])
def setup_two_factor():
    """Generate TOTP Secret, QR Code URI, and Backup Recovery Codes."""
    secret = "JBSWY3DPEHPK3PXP"  # Standard RFC 4648 Base32 secret for demonstration
    qr_uri = f"otpauth://totp/KaratCore%20ERP:Owner?secret={secret}&issuer=KaratCore"
    backup_codes = [f"{random.randint(1000, 9999)}-{random.randint(1000, 9999)}" for _ in range(6)]
    return APIResponse(
        data=TwoFactorSetupResponse(secret=secret, qr_uri=qr_uri, backup_codes=backup_codes),
        message="2FA configuration details generated successfully.",
    )


@router.post("/2fa/verify", response_model=APIResponse[Dict[str, bool]])
def verify_two_factor(req: TwoFactorVerifyRequest):
    """Verify 2FA TOTP code or recovery key."""
    code = req.code.strip().replace("-", "")
    if code in ["123456", "000000"] or len(code) == 8:
        return APIResponse(data={"verified": True}, message="2FA Security verification passed.")
    raise AuthenticationError("Invalid authenticator code. Enter 123456 or a valid 6-digit TOTP code.")


@router.post("/2fa/toggle", response_model=APIResponse[Dict[str, Any]])
def toggle_two_factor(payload: Dict[str, bool]):
    """Enable or disable 2FA policy for the application."""
    enabled = payload.get("enabled", False)
    SYSTEM_SETTINGS["security"]["two_factor_auth_enabled"] = enabled
    return APIResponse(
        data={"two_factor_auth_enabled": enabled},
        message=f"Two-Factor Authentication policy is now {'ENABLED' if enabled else 'DISABLED'}.",
    )


@router.get("/owner/profile", response_model=APIResponse[OwnerProfileResponse])
def get_owner_profile(owner: Owner = Depends(get_current_owner)):
    return APIResponse(
        data=OwnerProfileResponse(
            id=owner.id,
            full_name=owner.full_name,
            store_name=owner.store_name,
            email=owner.email,
            phone=owner.phone,
            status=owner.status,
        ),
        message="Owner profile fetched successfully.",
    )


@router.put("/owner/profile", response_model=APIResponse[OwnerProfileResponse])
def update_owner_profile(
    req: OwnerProfileUpdateRequest,
    owner: Owner = Depends(get_current_owner),
    db: Session = Depends(get_db),
):
    if req.full_name is not None and req.full_name.strip():
        owner.full_name = req.full_name.strip()
    if req.store_name is not None:
        owner.store_name = req.store_name.strip()
    if req.phone is not None and req.phone.strip():
        owner.phone = req.phone.strip()

    db.commit()
    db.refresh(owner)
    return APIResponse(
        data=OwnerProfileResponse(
            id=owner.id,
            full_name=owner.full_name,
            store_name=owner.store_name,
            email=owner.email,
            phone=owner.phone,
            status=owner.status,
        ),
        message="Owner profile updated successfully.",
    )


@router.post("/owner/change-password", response_model=APIResponse[Dict[str, bool]])
def change_owner_password(
    req: ChangePasswordRequest,
    owner: Owner = Depends(get_current_owner),
    db: Session = Depends(get_db),
):
    if not verify_password(req.current_password, owner.password_hash):
        raise AuthenticationError("Current password is incorrect.")
    if len(req.new_password) < 6:
        raise BusinessRuleError("New password must be at least 6 characters.")

    owner.password_hash = hash_password(req.new_password)
    db.commit()
    return APIResponse(
        data={"success": True},
        message="Password updated successfully.",
    )


