def test_unbalanced_journal_entry_fails(client, owner_headers):
    """Test that posting an unbalanced journal entry (Total Debits != Total Credits) returns 422 Unprocessable Entity."""
    unbalanced_payload = {
        "description": "Unbalanced Journal Entry Test",
        "lines": [
            {"account_id": 1, "debit": 1000.0, "credit": 0.0, "description": "Debit line"},
            {"account_id": 2, "debit": 0.0, "credit": 500.0, "description": "Credit line mismatch"},
        ],
    }
    res = client.post("/api/v1/accounting/journal-entries", json=unbalanced_payload, headers=owner_headers)
    assert res.status_code == 422
    body = res.json()
    err_msg = body.get("detail", {}).get("error", {}).get("message") or body.get("error", {}).get("message")
    assert "Unbalanced" in err_msg


def test_balanced_journal_entry_succeeds(client, owner_headers):
    """Test that posting a balanced journal entry (Total Debits == Total Credits) succeeds."""
    balanced_payload = {
        "description": "Balanced Test Journal",
        "lines": [
            {"account_id": 1, "debit": 2500.0, "credit": 0.0, "description": "Debit Cash"},
            {"account_id": 3, "debit": 0.0, "credit": 2500.0, "description": "Credit Income"},
        ],
    }
    res = client.post("/api/v1/accounting/journal-entries", json=balanced_payload, headers=owner_headers)
    assert res.status_code == 200
    assert res.json()["data"]["entry_number"] is not None
