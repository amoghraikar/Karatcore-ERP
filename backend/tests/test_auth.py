def test_owner_login_success(client):
    res = client.post(
        "/api/v1/auth/owner/login",
        json={"username": "testowner@karatcore.com", "password": "testpass123"},
    )
    assert res.status_code == 200
    token = res.json()["data"]["access_token"]
    assert token is not None


def test_owner_login_failure(client):
    res = client.post(
        "/api/v1/auth/owner/login",
        json={"username": "testowner@karatcore.com", "password": "wrongpassword"},
    )
    assert res.status_code == 401


def test_customer_login_success(client):
    res = client.post(
        "/api/v1/auth/customer/login",
        json={"customer_id": "TEST-CUST-A", "mobile": "+91 91111 11111"},
    )
    assert res.status_code == 200
    token = res.json()["data"]["access_token"]
    assert token is not None
