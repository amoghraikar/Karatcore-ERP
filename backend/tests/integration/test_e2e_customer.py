def test_e2e_customer_full_lifecycle(client, customer_a_headers):
    # 1. Customer Profile
    prof_res = client.get("/api/v1/customer/profile", headers=customer_a_headers)
    assert prof_res.status_code == 200
    assert prof_res.json()["data"]["id"] == "TEST-CUST-A"

    # 2. Customer Start KYC & Upload Document
    start_kyc = client.post("/api/v1/customer/kyc/start", headers=customer_a_headers)
    assert start_kyc.status_code == 200

    doc_res = client.post(
        "/api/v1/customer/kyc/documents",
        json={
            "document_type": "PASSPORT",
            "masked_identifier": "Z98471928",
            "file_name": "passport_copy.pdf",
            "mime_type": "application/pdf",
            "file_size": 1500000,
        },
        headers=customer_a_headers,
    )
    assert doc_res.status_code == 200

    consent_res = client.post(
        "/api/v1/customer/kyc/consent",
        json={"consent_type": "IDENTITY_VERIFICATION", "consent_text_version": "KYC_CONSENT_V1"},
        headers=customer_a_headers,
    )
    assert consent_res.status_code == 200

    sub_res = client.post("/api/v1/customer/kyc/submit", headers=customer_a_headers)
    assert sub_res.status_code == 200
    assert sub_res.json()["data"]["status"] == "UNDER_REVIEW"

    # 3. Customer Loans & Payments History
    loans_res = client.get("/api/v1/customer/loans", headers=customer_a_headers)
    assert loans_res.status_code == 200

    payments_res = client.get("/api/v1/customer/payments", headers=customer_a_headers)
    assert payments_res.status_code == 200
