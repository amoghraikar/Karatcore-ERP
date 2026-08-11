import uuid
from decimal import Decimal
from typing import Any, Dict
from app.services.payment_provider.base import PaymentGatewayProvider


class MockPaymentGatewayProvider(PaymentGatewayProvider):
    """
    Mock Payment Gateway Provider (DEMO / SIMULATED).
    DISCLAIMER: Fictional simulation only. Does NOT connect to Razorpay, Stripe, or any real payment gateway.
    """

    def __init__(self):
        self.provider_name = "DEMO_MOCK_PAYMENT_GATEWAY"

    def create_payment_order(self, customer_id: str, loan_id: str, amount: Decimal) -> Dict[str, Any]:
        order_id = f"MOCK-ORD-{uuid.uuid4().hex[:8].upper()}"
        return {
            "provider": self.provider_name,
            "external_order_id": order_id,
            "amount": amount,
            "currency": "INR",
            "status": "CREATED",
            "disclaimer": "DEMO / SIMULATED PAYMENT ORDER",
        }

    def get_payment_status(self, external_order_id: str) -> Dict[str, Any]:
        txn_id = f"MOCK-TXN-{uuid.uuid4().hex[:8].upper()}"
        return {
            "external_order_id": external_order_id,
            "external_transaction_id": txn_id,
            "status": "SUCCESS",
            "provider": self.provider_name,
            "disclaimer": "DEMO / SIMULATED TRANSACTION SUCCESS",
        }

    def verify_payment(self, external_order_id: str, signature: str) -> bool:
        return True

    def refund_payment(self, external_transaction_id: str, amount: Decimal, reason: str) -> Dict[str, Any]:
        return {
            "external_transaction_id": external_transaction_id,
            "refund_id": f"MOCK-REF-{uuid.uuid4().hex[:8].upper()}",
            "amount": amount,
            "status": "SUCCESS",
            "disclaimer": "DEMO / SIMULATED REFUND SUCCESS",
        }
