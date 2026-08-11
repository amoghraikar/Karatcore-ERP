# KaratCore ERP — Privacy & Data Mapping Document

## Data Inventory

| Data Category | Stored Elements | Storage Location | Access Controls | Retention Policy |
| :--- | :--- | :--- | :--- | :--- |
| **Owner Data** | Full Name, Email, Phone, Password Hash (`pbkdf2_sha256`) | PostgreSQL (`owners` table) | Owner-authenticated session only | Indefinite (business operator account) |
| **Customer Data** | Full Name, Phone, Email, Address, Occupation, Income Bracket | PostgreSQL (`customers` table) | Owner & Customer self-access only | Account lifetime + 7 years |
| **KYC Identity Proofs** | Document Type, Masked Identifier (`XXXX-XXXX-8821`), Storage Ref, Mime Type, Size | PostgreSQL (`kyc_document_metadata` table) & Private Storage | Owner Reviewer & Customer self-access | 7 years (regulatory requirement) |
| **Pledge & Loan Contracts** | Principal, Interest Rate, Dates, Outstanding Balances | PostgreSQL (`loans` & `pledges` tables) | Owner & Customer self-access | Permanent general ledger record |
| **Payments & Receipts** | Payment Code, Amount, Method, Date, Receipt Number (`KC-RCP-2026-XXXXXX`) | PostgreSQL (`loan_payments` & `receipts` tables) | Owner & Customer self-access | Permanent financial record |
| **Audit Logs** | Actor Type, Actor ID, Action, Timestamp, Metadata | PostgreSQL (`audit_events` table) | Owner-only diagnostic view | 5 years |
