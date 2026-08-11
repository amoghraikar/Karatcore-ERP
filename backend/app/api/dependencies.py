from typing import Optional
from fastapi import Depends, Header, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.exceptions import AuthenticationError, AuthorizationError
from app.core.security import decode_token
from app.models.customer import Customer
from app.models.owner import Owner


def get_token_payload(authorization: Optional[str] = Header(None)) -> dict:
    if not authorization or not authorization.startswith("Bearer "):
        raise AuthenticationError("Missing or invalid Bearer token format")

    token = authorization.split(" ")[1]
    payload = decode_token(token)
    if not payload:
        raise AuthenticationError("Invalid or expired access token")
    return payload


def get_current_owner(
    payload: dict = Depends(get_token_payload),
    db: Session = Depends(get_db),
) -> Owner:
    user_type = payload.get("user_type")
    if user_type != "owner":
        raise AuthorizationError("Owner access required for this internal endpoint.")

    owner_id = payload.get("sub")
    owner = db.query(Owner).filter(Owner.email == owner_id).first()
    if not owner:
        raise AuthenticationError("Owner user account not found.")
    return owner


def get_current_customer(
    payload: dict = Depends(get_token_payload),
    db: Session = Depends(get_db),
) -> Customer:
    user_type = payload.get("user_type")
    if user_type != "customer":
        raise AuthorizationError("Customer portal authentication required.")

    customer_id = payload.get("customer_id") or payload.get("sub")
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer:
        raise AuthenticationError("Customer profile not found.")
    return customer
