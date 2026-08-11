def test_double_entry_unbalanced_rejection(client, owner_headers):
    # Attempt to post unbalanced journal entry (Debit 100 != Credit 50)
    unbalanced_payload = {
        "description": "Unbalanced test transaction",
        "lines": [
            {"account_id": 1, "debit": 100.0, "credit": 0.0, "description": "Cash in"},
            {"account_id": 2, "debit": 0.0, "credit": 50.0, "description": "Partial credit"},
        ],
    }
    res = client.post("/api/v1/accounting/journal-entries", json=unbalanced_payload, headers=owner_headers)
    assert res.status_code == 422


def test_payment_idempotency_prevents_duplicate_financial_records(client, owner_headers):
    payload = {
        "loan_id": "TEST-LOAN-A",
        "amount": "1200.00",
        "principal_amount": "1000.00",
        "interest_amount": "200.00",
        "idempotency_key": "IDEM-FINANCIAL-INTEGRITY-888",
    }
    res1 = client.post("/api/v1/payments", json=payload, headers=owner_headers)
    assert res1.status_code == 200
    pay1_id = res1.json()["data"]["id"]

    res2 = client.post("/api/v1/payments", json=payload, headers=owner_headers)
    assert res2.status_code == 200
    pay2_id = res2.json()["data"]["id"]

    assert pay1_id == pay2_id
