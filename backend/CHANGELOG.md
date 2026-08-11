# KaratCore ERP — Release Changelog

## [1.0.0] - 2026-08-11

### Initial Production Release Architecture
- **Single-Owner ERP Access Model**: Hardened authorization model for 1 Store Owner + Customer Portal.
- **Backend Stack**: Production Python 3.12+, FastAPI, PostgreSQL, SQLAlchemy 2.x declarative entities, Alembic migrations.
- **Financial Precision Engine**: Strict `Numeric(12, 2)` / Python `Decimal` arithmetic across Loan Balances, Payments, Receipts, and General Ledger journal entries.
- **Double-Entry Accounting Enforcement**: Enforces `sum(debit) == sum(credit)` balancing on every transaction with atomic rollback.
- **KYC & Identity Integration Layer**: Manual Document Upload (10MB limit, server-side storage references) + Mock Digital Provider (`MockIdentityVerificationProvider`) with versioned consent (`KYC_CONSENT_V1`).
- **Payment Architecture**: Owner payment recording, receipt generation (`KC-RCP-2026-XXXXXX`), idempotency key deduplication, payment reversals, and webhooks receiver.
- **Security Hardening**: JWT authentication, PBKDF2/bcrypt hashing, rate-limiting login protection, security headers (`nosniff`, `DENY`), request ID correlation headers (`X-Request-ID`), and Customer Data Isolation.
- **Deployment & Containerization**: Multi-stage Dockerfile (non-root `appuser`), `docker-compose.dev.yml`, GitHub Actions CI pipeline, and Flutter build-time environment configuration (`--dart-define`).
