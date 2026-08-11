from abc import ABC, abstractmethod
from typing import Any, Dict, Optional


class IdentityVerificationProvider(ABC):
    @abstractmethod
    def create_verification_session(self, customer_id: str, kyc_id: int) -> Dict[str, Any]:
        """Initialize verification session with external identity provider."""
        pass

    @abstractmethod
    def get_verification_status(self, provider_session_id: str) -> Dict[str, Any]:
        """Query verification session status."""
        pass

    @abstractmethod
    def retrieve_verified_identity(self, provider_session_id: str) -> Optional[Dict[str, Any]]:
        """Retrieve verified identity details if session completed."""
        pass
