import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional
from app.services.identity_provider.base import IdentityVerificationProvider


class MockIdentityVerificationProvider(IdentityVerificationProvider):
    """
    Mock Identity Verification Provider (DEMO / SIMULATED).
    DISCLAIMER: Fictional simulation only. Does NOT connect to any government system or DigiLocker API.
    """

    def __init__(self):
        self.provider_name = "DEMO_MOCK_IDENTITY_PROVIDER"

    def create_verification_session(self, customer_id: str, kyc_id: int) -> Dict[str, Any]:
        session_id = f"MOCK-SESS-{uuid.uuid4().hex[:8].upper()}"
        now = datetime.now(timezone.utc)
        return {
            "provider": self.provider_name,
            "provider_session_id": session_id,
            "status": "SESSION_CREATED",
            "created_at": now,
            "expires_at": now + timedelta(minutes=15),
            "disclaimer": "DEMO / SIMULATED VERIFICATION SESSION",
        }

    def get_verification_status(self, provider_session_id: str) -> Dict[str, Any]:
        return {
            "provider_session_id": provider_session_id,
            "status": "VERIFIED",
            "completed_at": datetime.now(timezone.utc),
            "disclaimer": "DEMO / SIMULATED VERIFICATION RESULT",
        }

    def retrieve_verified_identity(self, provider_session_id: str) -> Optional[Dict[str, Any]]:
        return {
            "provider_session_id": provider_session_id,
            "verification_source": "SIMULATED_TEST_PROVIDER",
            "name": "Simulated Test Identity",
            "masked_identifier": "XXXX-XXXX-9988",
            "verified": True,
        }
