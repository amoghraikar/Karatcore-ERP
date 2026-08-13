def test_owner_register_success(client):
    res = client.post(
        "/api/v1/auth/owner/register",
        json={
            "full_name": "New Operator",
            "business_name": "Karat Jewellery Store",
            "phone": "+91 99999 88888",
            "email": "newoperator@karatcore.com",
            "password": "SecurePassword123!",
        },
    )
    assert res.status_code == 200
    token = res.json()["data"]["access_token"]
    assert token is not None


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
