from datetime import datetime
from typing import Any, Dict
from fastapi import APIRouter, Body, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.owner import Owner

router = APIRouter(prefix="/settings", tags=["settings"])

# Base settings store for backend API
SYSTEM_SETTINGS: Dict[str, Any] = {
    "business": {
        "store_name": "Karatcore Jewellery & Gold Loans",
        "tagline": "Trusted Gold Loans & Certified Jewellery",
        "bis_registration_no": "BIS-HM-MH-400002-9812",
        "gstin": "27AAACV9812A1Z4",
        "owner_name": "Store Owner",
        "contact_email": "owner@karatcore.com",
        "contact_phone": "+91 98200 12345",
        "address": "Zaveri Bazaar, Mumbai, MH 400002",
        "currency_symbol": "₹",
    },
    "security": {
        "require_biometric_lock": True,
        "require_owner_pin_for_actions": True,
        "session_timeout_minutes": 15,
        "two_factor_auth_enabled": False,
        "audit_log_retention_days": 365,
    },
    "financial": {
        "gold_24k_rate_per_gram": 7450.0,
        "gold_22k_rate_per_gram": 6830.0,
        "gold_18k_rate_per_gram": 5580.0,
        "silver_rate_per_gram": 88.0,
        "max_ltv_percentage": 75.0,
        "default_monthly_interest_rate": 1.5,
        "penalty_interest_rate": 2.0,
        "min_tenure_days": 7,
        "max_tenure_months": 36,
    },
    "notifications": {
        "enable_sms_alerts": True,
        "enable_whatsapp_reminders": True,
        "enable_email_notifications": False,
        "due_reminder_days_before": 3,
        "overdue_repeat_interval_days": 7,
    },
    "last_updated": datetime.now().isoformat(),
    "updated_by": "Chief Administrator",
}


@router.get("", response_model=Dict[str, Any])
async def get_settings(db: Session = Depends(get_db)) -> Dict[str, Any]:
    """Get system-wide settings, rates, security parameters & store profile dynamically from DB."""
    owner = db.query(Owner).order_by(Owner.created_at.desc()).first()
    if owner:
        if "custom_store_name" not in SYSTEM_SETTINGS["business"]:
            if owner.store_name:
                SYSTEM_SETTINGS["business"]["store_name"] = owner.store_name
            else:
                SYSTEM_SETTINGS["business"]["store_name"] = f"{owner.full_name}'s Jewellery & Gold Loans"
        SYSTEM_SETTINGS["business"]["owner_name"] = owner.full_name
        SYSTEM_SETTINGS["business"]["contact_email"] = owner.email
        SYSTEM_SETTINGS["business"]["contact_phone"] = owner.phone

    return SYSTEM_SETTINGS


@router.post("/business", response_model=Dict[str, Any])
async def update_business_settings(payload: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """Update store legal profile & contact information."""
    if "store_name" in payload:
        SYSTEM_SETTINGS["business"]["custom_store_name"] = True
    SYSTEM_SETTINGS["business"].update(payload)
    SYSTEM_SETTINGS["last_updated"] = datetime.now().isoformat()
    return SYSTEM_SETTINGS


@router.post("/security", response_model=Dict[str, Any])
async def update_security_settings(payload: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """Update security policy & authentication parameters."""
    SYSTEM_SETTINGS["security"].update(payload)
    SYSTEM_SETTINGS["last_updated"] = datetime.now().isoformat()
    return SYSTEM_SETTINGS


@router.post("/financial", response_model=Dict[str, Any])
async def update_financial_settings(payload: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """Update gold/silver rates, LTV caps & interest matrices."""
    SYSTEM_SETTINGS["financial"].update(payload)
    SYSTEM_SETTINGS["last_updated"] = datetime.now().isoformat()
    return SYSTEM_SETTINGS


@router.post("/notifications", response_model=Dict[str, Any])
async def update_notification_settings(payload: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """Update notification channels & reminder schedule."""
    SYSTEM_SETTINGS["notifications"].update(payload)
    SYSTEM_SETTINGS["last_updated"] = datetime.now().isoformat()
    return SYSTEM_SETTINGS


@router.post("/reset", response_model=Dict[str, Any])
async def reset_settings() -> Dict[str, Any]:
    """Reset system settings to default factory values."""
    global SYSTEM_SETTINGS
    SYSTEM_SETTINGS["last_updated"] = datetime.now().isoformat()
    return SYSTEM_SETTINGS
