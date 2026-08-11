# KaratCore ERP — Production Readiness Checklist

## Checklist Overview

### 1. Security & Authentication
- [x] Passwords hashed with `pbkdf2_sha256` / `argon2`.
- [x] JWT token authentication with configurable secret key & expiration.
- [x] Single-Owner ERP authorization enforced.
- [x] Customer data isolation verified (Customer A cannot access Customer B data).
- [x] Sensitive identity numbers masked (`XXXX-XXXX-8821`, `ABCPS****F`).
- [x] Request ID correlation header (`X-Request-ID`) attached to all responses.
- [x] Security headers (`nosniff`, `DENY`, `XSS-Protection`) enabled.
- [x] Rate limiting active on authentication endpoints.

### 2. Database & Financial Integrity
- [x] PostgreSQL supported with SQLAlchemy 2.x declarative entities.
- [x] Alembic migration scripts baseline (`001`, `002`, `003`).
- [x] Monetary calculations enforced via `Numeric(12, 2)` and Python `Decimal` (Float prohibited).
- [x] Double-entry accounting rule (`sum(debit) == sum(credit)`) enforced with atomic transaction rollback.
- [x] Deterministic unique receipt numbering (`KC-RCP-2026-XXXXXX`).
- [x] Payment idempotency keys preventing duplicate financial postings.
- [x] Collateral single-pledge rule enforced.

### 3. Testing & Verification
- [x] Complete Pytest test suite (`unit`, `integration`, `security`, `financial`, `e2e`) passing 100%.
- [x] Flutter static code analysis (`flutter analyze`) passing with 0 errors and 0 warnings.
