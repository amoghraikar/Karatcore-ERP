# KaratCore ERP — Security Policy & Guidelines

## Architecture & Data Access Model
KaratCore ERP enforces a strict single-owner operational model:
- **Owner**: Full access to shop ERP operations (Customers, Loans, Inventory, Accounting, Reports).
- **Customer**: Strictly isolated access to their own data (Profile, KYC, Jewellery, Loans, Payments, Receipts, Notifications).

## Security Standards & Controls

### 1. Passwords & Hashing
- Passwords are salted and hashed using `pbkdf2_sha256` / `argon2`.
- Passwords, hashes, and raw credentials are **never stored plaintext**, **never returned by APIs**, and **never logged**.

### 2. JWT & Token Management
- HS256 JWT tokens with configurable expiration (`ACCESS_TOKEN_EXPIRE_MINUTES`).
- JWT payloads contain only non-sensitive claims (`sub`, `user_type`, `customer_id`/`owner_id`, `exp`, `iat`).

### 3. Customer Data Isolation & IDOR Protection
- Every customer route (`/api/v1/customer/*`) validates `authenticated_customer.id == target_resource.customer_id`.
- Cross-customer access attempts return `404 Not Found` / `403 Access Restricted` with zero data leakage.

### 4. Financial & Accounting Precision
- Binary floating-point arithmetic is strictly prohibited for money.
- All monetary fields use `Numeric(12, 2)` in SQLAlchemy / PostgreSQL and Python `Decimal`.
- Double-entry rule (`sum(debit) == sum(credit)`) is enforced on every posted journal entry. Unbalanced entries trigger immediate database transaction rollbacks.

### 5. File Upload & KYC Privacy
- Document metadata is stored with masked identifiers (e.g. `XXXX-XXXX-8821`, `ABCPS****F`).
- File uploads are validated server-side (max 10 MB limit, strict MIME type filtering: JPEG, PNG, WEBP, PDF).
- Raw document files are saved with server-generated non-predictable UUID storage references outside the web root.

### 6. Secrets & Environment Separation
- Database credentials, JWT secret keys, and API keys are stored in environment variables (`.env`).
- Production secrets are excluded from Git repositories (`.gitignore`).
