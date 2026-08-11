# KaratCore ERP — Pre-Deployment Production Checklist

- [x] **Environment Separation**: Distinct settings for `development`, `testing`, `staging`, and `production`.
- [x] **Fail-Fast Configuration**: Startup fails immediately if `JWT_SECRET_KEY` uses dev defaults in `APP_ENV=production`.
- [x] **Multi-Stage Dockerfile**: Production container image runs under non-root `appuser` (UID 10001).
- [x] **PostgreSQL & Alembic**: Database migrations verified via `alembic upgrade head`.
- [x] **Financial Precision**: All money fields use `Numeric(12, 2)` / Python `Decimal`.
- [x] **Double-Entry Balance**: Every posted journal entry satisfies `debit == credit`.
- [x] **Customer Isolation**: Customer A cannot access Customer B's records across all APIs.
- [x] **Background Job Abstraction**: `TaskService` handles idempotent loan due reminders and reconciliation.
- [x] **CI/CD Pipeline**: GitHub Actions workflow defined in `.github/workflows/ci.yml`.
- [x] **Flutter Production Build**: Compile-time environment configuration wired in `EnvConfig`.
- [x] **Changelog & Documentation**: Release 1.0.0 documented in `CHANGELOG.md`.
