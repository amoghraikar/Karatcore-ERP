# KaratCore ERP — Disaster Recovery & Backup Plan

## Recovery Metrics Target
- **Recovery Point Objective (RPO)**: < 1 hour (automated hourly WAL/point-in-time PostgreSQL backups).
- **Recovery Time Objective (RTO)**: < 4 hours (automated container/database restore playbook).

## Backup Architecture & Policy

### 1. Database Backups
- **Daily Automated Full Backups**: Encrypted `pg_dump` snapshots stored in off-site encrypted S3 object storage.
- **Retention Schedule**:
  - Daily backups retained for 30 days.
  - Weekly backups retained for 90 days.
  - Monthly backups retained for 7 years (compliance requirement for financial ledger records).

### 2. Document & KYC Backup Policy
- Private document storage volumes replicated asynchronously to secondary cloud storage buckets.

## Disaster Recovery Procedure

### Scenario 1: Database Failure / Corruption
1. Provision clean PostgreSQL instance in secondary zone.
2. Fetch latest encrypted dump file from S3 off-site storage.
3. Restore database schema and data using `pg_restore`.
4. Execute `alembic upgrade head` to ensure schema alignment.
5. Run Owner Diagnostic Integrity Audit: `/api/v1/diagnostics/check`.

### Scenario 2: Secret / Credential Compromise
1. Immediately rotate `JWT_SECRET_KEY` and database credentials in production Secret Manager.
2. Redeploy backend containers to force invalidation of active sessions.
3. Require Owner & Customer login re-authentication.
