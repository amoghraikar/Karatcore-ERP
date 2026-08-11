"""003_payments_integration_schema

Revision ID: 003_payments_integration_schema
Revises: 002_kyc_identity_schema
Create Date: 2026-08-11 20:20:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = '003_payments_integration_schema'
down_revision: Union[str, None] = '002_kyc_identity_schema'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Baseline migration for Numeric(12, 2) payment integration schema.
    pass


def downgrade() -> None:
    pass
