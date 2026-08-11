def test_e2e_owner_full_lifecycle(client, owner_headers):
    # 1. Check Owner Login & Health
    health = client.get("/health")
    assert health.status_code == 200

    ready = client.get("/health/ready")
    assert ready.status_code == 200

    # 2. Query Owner Customers
    customers = client.get("/api/v1/customers", headers=owner_headers)
    assert customers.status_code == 200

    # 3. Query Owner KYC Queue & Metrics
    metrics = client.get("/api/v1/kyc/metrics", headers=owner_headers)
    assert metrics.status_code == 200

    # 4. Record Owner Payment
    payment_payload = {
        "loan_id": "TEST-LOAN-A",
        "amount": "2000.00",
        "principal_amount": "1500.00",
        "interest_amount": "500.00",
        "payment_method": "CASH",
        "idempotency_key": "IDEM-E2E-OWNER-KEY-101",
    }
    pay_res = client.post("/api/v1/payments", json=payment_payload, headers=owner_headers)
    assert pay_res.status_code == 200
    payment_id = pay_res.json()["data"]["id"]

    # 5. Fetch Receipt
    receipt_res = client.get(f"/api/v1/payments/{payment_id}/receipt", headers=owner_headers)
    assert receipt_res.status_code == 200
    assert "KC-RCP-2026-" in receipt_res.json()["data"]["receipt_number"]

    # 6. Run System Health & Financial Audit Diagnostics
    diag_res = client.get("/api/v1/diagnostics/check", headers=owner_headers)
    assert diag_res.status_code == 200
    assert diag_res.json()["data"]["status"] == "CLEAN"
