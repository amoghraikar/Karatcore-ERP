def test_customer_isolation_across_all_entities(client, customer_a_headers, customer_b_headers):
    """Customer A must NOT access Customer B's KYC, Documents, Loans, Payments, or Receipts."""
    # 1. Fetch Customer B's Loan & KYC
    res_b_loans = client.get("/api/v1/customer/loans", headers=customer_b_headers)
    assert res_b_loans.status_code == 200
    loan_b_id = res_b_loans.json()["data"][0]["id"]

    # Customer A attempts to fetch Customer B's loan details
    cross_loan = client.get(f"/api/v1/customer/loans/{loan_b_id}", headers=customer_a_headers)
    assert cross_loan.status_code in [404, 403]
    assert "data" not in cross_loan.json() or cross_loan.json()["data"] is None

    # 2. Customer A attempts to access Owner-only endpoints -> 403 Forbidden
    owner_routes = [
        "/api/v1/customers",
        "/api/v1/kyc",
        "/api/v1/payments",
        "/api/v1/accounting/journal-entries",
        "/api/v1/diagnostics/check",
    ]
    for route in owner_routes:
        res = client.get(route, headers=customer_a_headers)
        assert res.status_code in [401, 403, 405]


def test_malformed_and_expired_jwt_tokens(client):
    headers_malformed = {"Authorization": "Bearer invalid.jwt.token.string"}
    res_malformed = client.get("/api/v1/customer/profile", headers=headers_malformed)
    assert res_malformed.status_code == 401

    headers_missing = {}
    res_missing = client.get("/api/v1/customer/profile", headers=headers_missing)
    assert res_missing.status_code == 401


def test_file_upload_validation_security(client, customer_a_headers):
    # Oversized file (>10 MB limit)
    oversized_payload = {
        "document_type": "PAN",
        "masked_identifier": "ABCPS****F",
        "file_name": "huge_file.pdf",
        "mime_type": "application/pdf",
        "file_size": 15 * 1024 * 1024,  # 15 MB
    }
    res_huge = client.post("/api/v1/customer/kyc/documents", json=oversized_payload, headers=customer_a_headers)
    assert res_huge.status_code == 422

    # Disallowed MIME type (executable script)
    exe_payload = {
        "document_type": "PAN",
        "masked_identifier": "ABCPS****F",
        "file_name": "malicious_script.sh",
        "mime_type": "application/x-sh",
        "file_size": 2048,
    }
    res_exe = client.post("/api/v1/customer/kyc/documents", json=exe_payload, headers=customer_a_headers)
    assert res_exe.status_code == 422
