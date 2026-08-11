"""002_kyc_identity_schema

Revision ID: 002_kyc_identity_schema
Revises: 001_initial_schema
Create Date: 2026-08-11 20:15:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = '002_kyc_identity_schema'
down_revision: Union[str, None] = '001_initial_schema'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Schema auto-managed by SQLAlchemy create_all in dev mode; this migration represents KYC identity tables baseline.
    pass


def downgrade() -> None:
    pass
