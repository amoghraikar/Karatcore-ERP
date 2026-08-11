def test_customer_a_can_read_own_loans(client, customer_a_headers):
    res = client.get("/api/v1/customer/loans", headers=customer_a_headers)
    assert res.status_code == 200
    data = res.json()["data"]
    assert len(data) >= 1
    assert data[0]["id"] == "TEST-LOAN-A"


def test_customer_a_cannot_access_customer_b_loan(client, customer_a_headers):
    """CRITICAL SECURITY ISOLATION TEST: Customer A attempting to access Customer B's loan must return 404/403 with no data leak."""
    res = client.get("/api/v1/customer/loans/TEST-LOAN-B", headers=customer_a_headers)
    assert res.status_code in [404, 403]
    body = res.json()
    assert "data" not in body or body["data"] is None
    assert "detail" in body or "error" in body


def test_customer_b_cannot_access_customer_a_loan(client, customer_b_headers):
    """CRITICAL SECURITY ISOLATION TEST: Customer B attempting to access Customer A's loan must return 404/403 with no data leak."""
    res = client.get("/api/v1/customer/loans/TEST-LOAN-A", headers=customer_b_headers)
    assert res.status_code in [404, 403]
    body = res.json()
    assert "data" not in body or body["data"] is None
    assert "detail" in body or "error" in body
