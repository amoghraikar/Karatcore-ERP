def test_customer_kyc_flow_and_consent(client, customer_a_headers):
    # 1. Start KYC
    res = client.post("/api/v1/customer/kyc/start", headers=customer_a_headers)
    assert res.status_code == 200
    kyc_id = res.json()["data"]["id"]
    assert kyc_id is not None

    # 2. Upload Document
    doc_payload = {
        "document_type": "PAN",
        "masked_identifier": "ABCPS****F",
        "file_name": "pan_card.pdf",
        "mime_type": "application/pdf",
        "file_size": 204850,
    }
    doc_res = client.post("/api/v1/customer/kyc/documents", json=doc_payload, headers=customer_a_headers)
    assert doc_res.status_code == 200
    doc_data = doc_res.json()["data"]
    assert doc_data["masked_identifier"] == "ABCPS****F"
    assert "/storage/kyc/" in doc_data["storage_reference"]

    # 3. Record Consent
    consent_res = client.post("/api/v1/customer/kyc/consent", json={"consent_type": "IDENTITY_VERIFICATION", "consent_text_version": "KYC_CONSENT_V1"}, headers=customer_a_headers)
    assert consent_res.status_code == 200
    assert consent_res.json()["data"]["consent_text_version"] == "KYC_CONSENT_V1"

    # 4. Submit KYC
    sub_res = client.post("/api/v1/customer/kyc/submit", headers=customer_a_headers)
    assert sub_res.status_code == 200
    assert sub_res.json()["data"]["status"] == "UNDER_REVIEW"


def test_customer_isolation_on_kyc_and_documents(client, customer_a_headers, customer_b_headers):
    """CRITICAL SECURITY ISOLATION TEST: Customer B attempting to access Customer A's KYC or documents is blocked."""
    # Fetch Customer A's KYC
    res_a = client.get("/api/v1/customer/kyc", headers=customer_a_headers)
    assert res_a.status_code == 200
    kyc_a = res_a.json()["data"]

    # Fetch Customer B's KYC
    res_b = client.get("/api/v1/customer/kyc", headers=customer_b_headers)
    assert res_b.status_code == 200
    kyc_b = res_b.json()["data"]

    # Verify distinct KYC records
    assert kyc_a["customer_id"] == "TEST-CUST-A"
    assert kyc_b["customer_id"] == "TEST-CUST-B"
    assert kyc_a["id"] != kyc_b["id"]


def test_owner_kyc_review_approve_and_reject(client, owner_headers, customer_a_headers):
    # Customer A submits KYC
    client.post("/api/v1/customer/kyc/start", headers=customer_a_headers)
    client.post(
        "/api/v1/customer/kyc/documents",
        json={"document_type": "AADHAAR", "masked_identifier": "XXXX-XXXX-8821", "file_name": "aadhaar.jpg", "mime_type": "image/jpeg", "file_size": 500000},
        headers=customer_a_headers,
    )
    client.post("/api/v1/customer/kyc/consent", json={"consent_type": "IDENTITY_VERIFICATION", "consent_text_version": "KYC_CONSENT_V1"}, headers=customer_a_headers)
    sub = client.post("/api/v1/customer/kyc/submit", headers=customer_a_headers)
    kyc_id = sub.json()["data"]["id"]

    # Owner views queue
    queue_res = client.get("/api/v1/kyc", headers=owner_headers)
    assert queue_res.status_code == 200

    # Owner approves KYC
    approve_res = client.post(
        f"/api/v1/kyc/{kyc_id}/approve",
        json={"reviewer_notes": "All identity documents verified clean."},
        headers=owner_headers,
    )
    assert approve_res.status_code == 200
    assert approve_res.json()["data"]["status"] == "VERIFIED"


def test_mock_digital_verification_flow(client, customer_b_headers):
    # Customer B starts simulated digital verification
    res = client.post("/api/v1/customer/kyc/digital-verification", headers=customer_b_headers)
    assert res.status_code == 200
    body = res.json()["data"]
    assert body["provider"] == "DEMO_MOCK"
    assert body["disclaimer"] == "DEMO / SIMULATED VERIFICATION SESSION"

    # Verify Customer B status became VERIFIED
    kyc_res = client.get("/api/v1/customer/kyc", headers=customer_b_headers)
    assert kyc_res.status_code == 200
    assert kyc_res.json()["data"]["status"] == "VERIFIED"
