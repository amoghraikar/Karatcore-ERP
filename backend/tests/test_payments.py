from decimal import Decimal
import pytest


def test_payment_recording_and_receipt_generation(client, owner_headers):
    payload = {
        "loan_id": "TEST-LOAN-A",
        "amount": "1000.00",
        "principal_amount": "800.00",
        "interest_amount": "200.00",
        "payment_method": "CASH",
        "payment_source": "OWNER_RECORDED",
        "idempotency_key": "IDEM-TEST-KEY-001",
    }
    res = client.post("/api/v1/payments", json=payload, headers=owner_headers)
    assert res.status_code == 200
    data = res.json()["data"]
    assert data["amount"] == "1000.00"
    payment_id = data["id"]

    # Verify Receipt generated
    rec_res = client.get(f"/api/v1/payments/{payment_id}/receipt", headers=owner_headers)
    assert rec_res.status_code == 200
    receipt = rec_res.json()["data"]
    assert "KC-RCP-2026-" in receipt["receipt_number"]
    assert Decimal(receipt["remaining_balance"]) < Decimal("50000.00")


def test_payment_idempotency_prevents_duplicate_payments(client, owner_headers):
    payload = {
        "loan_id": "TEST-LOAN-A",
        "amount": "500.00",
        "principal_amount": "400.00",
        "interest_amount": "100.00",
        "idempotency_key": "IDEM-DUPLICATE-CHECK-999",
    }
    res1 = client.post("/api/v1/payments", json=payload, headers=owner_headers)
    assert res1.status_code == 200
    pay1_id = res1.json()["data"]["id"]

    # Resubmit identical request with same idempotency key
    res2 = client.post("/api/v1/payments", json=payload, headers=owner_headers)
    assert res2.status_code == 200
    pay2_id = res2.json()["data"]["id"]

    assert pay1_id == pay2_id


def test_payment_allocation_mismatch_fails(client, owner_headers):
    payload = {
        "loan_id": "TEST-LOAN-A",
        "amount": "1000.00",
        "principal_amount": "500.00",
        "interest_amount": "400.00",  # 500 + 400 = 900 != 1000
    }
    res = client.post("/api/v1/payments", json=payload, headers=owner_headers)
    assert res.status_code == 422


def test_customer_isolation_on_payments_and_receipts(client, customer_a_headers, customer_b_headers, owner_headers):
    # Owner records payment for Customer A (TEST-LOAN-A)
    payload = {
        "loan_id": "TEST-LOAN-A",
        "amount": "1500.00",
        "principal_amount": "1000.00",
        "interest_amount": "500.00",
        "idempotency_key": "IDEM-ISOLATION-TEST-101",
    }
    p_res = client.post("/api/v1/payments", json=payload, headers=owner_headers)
    pay_id = p_res.json()["data"]["id"]

    # Customer A accesses own payment -> 200 OK
    res_a = client.get(f"/api/v1/customer/payments/{pay_id}", headers=customer_a_headers)
    assert res_a.status_code == 200

    # Customer B attempts to access Customer A's payment -> 404 / 403 Access Restricted
    res_b = client.get(f"/api/v1/customer/payments/{pay_id}", headers=customer_b_headers)
    assert res_b.status_code in [404, 403]
    assert "data" not in res_b.json() or res_b.json()["data"] is None

    # Customer B attempts to access Customer A's receipt -> 404 / 403 Access Restricted
    rec_b = client.get(f"/api/v1/customer/payments/{pay_id}/receipt", headers=customer_b_headers)
    assert rec_b.status_code in [404, 403]


def test_payment_reversal_flow(client, owner_headers):
    # Record payment
    payload = {
        "loan_id": "TEST-LOAN-A",
        "amount": "2000.00",
        "principal_amount": "1500.00",
        "interest_amount": "500.00",
        "idempotency_key": "IDEM-REVERSAL-TEST-202",
    }
    p_res = client.post("/api/v1/payments", json=payload, headers=owner_headers)
    pay_id = p_res.json()["data"]["id"]

    # Perform Reversal
    rev_res = client.post(f"/api/v1/payments/{pay_id}/reverse", json={"reason": "Check bounced / customer request"}, headers=owner_headers)
    assert rev_res.status_code == 200
    assert rev_res.json()["data"]["payment_id"] == pay_id


def test_mock_payment_order_flow(client, customer_a_headers):
    order_payload = {
        "loan_id": "TEST-LOAN-A",
        "amount": "3000.00",
        "principal_amount": "2500.00",
        "interest_amount": "500.00",
    }
    res = client.post("/api/v1/customer/payment-orders", json=order_payload, headers=customer_a_headers)
    assert res.status_code == 200
    data = res.json()["data"]
    assert "MOCK-ORD-" in data["external_order_id"]
    assert data["disclaimer"] == "DEMO / SIMULATED PAYMENT ORDER"
