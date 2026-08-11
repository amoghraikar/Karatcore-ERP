from abc import ABC, abstractmethod
from decimal import Decimal
from typing import Any, Dict, Optional


class PaymentGatewayProvider(ABC):
    @abstractmethod
    def create_payment_order(self, customer_id: str, loan_id: str, amount: Decimal) -> Dict[str, Any]:
        """Create online payment order session."""
        pass

    @abstractmethod
    def get_payment_status(self, external_order_id: str) -> Dict[str, Any]:
        """Query payment transaction status."""
        pass

    @abstractmethod
    def verify_payment(self, external_order_id: str, signature: str) -> bool:
        """Verify payment transaction signature."""
        pass

    @abstractmethod
    def refund_payment(self, external_transaction_id: str, amount: Decimal, reason: str) -> Dict[str, Any]:
        """Initiate provider refund."""
        pass
