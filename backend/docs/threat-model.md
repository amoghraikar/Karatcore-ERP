# KaratCore ERP — Threat Model & Risk Mitigations

## Threat Matrix

| Threat Category | Potential Impact | Current Mitigation Strategy |
| :--- | :--- | :--- |
| **Unauthorized Cross-Customer Data Access (IDOR)** | High: Customer A accessing Customer B's loans, receipts, or KYC documents. | Customer endpoints strictly filter by `authenticated_customer.id == resource.customer_id`. Unauthorized requests return `404/403` with zero data leak. |
| **Brute Force Authentication Attacks** | Medium: Password guessing against Owner / Customer login. | Rate limiting middleware throttles authentication attempts to max 5 per minute per IP address. Failed attempts trigger security log events. |
| **Financial Entry Unbalancing** | Critical: Unbalanced debits/credits corrupting general ledger. | `AccountingService` validates `sum(debit) == sum(credit)` using `Decimal` precision before committing. Unbalanced entries trigger immediate database transaction rollback. |
| **Duplicate Payment Submissions / Replay** | High: Double-charging or duplicate receipt generation. | Idempotency keys (`idempotency_key`) and external transaction deduplication prevent duplicate financial mutations. |
| **Malicious File Uploads** | High: Path traversal or executable file upload via KYC portal. | Server-side MIME validation, 10MB size limit, server-generated safe UUID storage paths, non-public document access. |
| **Data Leakage in Server Logs** | Medium: Password, token, Aadhaar, or PAN numbers leaking into logs. | Identifiers are masked in database/schemas (`XXXX-XXXX-8821`), and request parameters/logs exclude raw identity numbers. |
