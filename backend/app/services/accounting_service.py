import random
from datetime import datetime, timezone
from typing import List
from sqlalchemy.orm import Session
from app.core.exceptions import AccountingUnbalancedError
from app.models.accounting import JournalEntry, JournalEntryLine
from app.repositories.accounting_repo import AccountingRepository
from app.schemas.accounting import JournalEntryCreate


class AccountingService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = AccountingRepository(db)

    def post_journal_entry(self, entry_in: JournalEntryCreate) -> JournalEntry:
        total_debit = sum(round(line.debit, 2) for line in entry_in.lines)
        total_credit = sum(round(line.credit, 2) for line in entry_in.lines)

        # Enforce Double-Entry Rule: TOTAL DEBITS = TOTAL CREDITS
        if abs(total_debit - total_credit) > 0.001:
            raise AccountingUnbalancedError(debit_sum=total_debit, credit_sum=total_credit)

        entry_num = f"JE-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000, 9999)}"
        journal_entry = JournalEntry(
            entry_number=entry_num,
            entry_date=datetime.now(timezone.utc),
            description=entry_in.description,
            reference_type=entry_in.reference_type,
            reference_id=entry_in.reference_id,
            status="POSTED",
        )

        lines = [
            JournalEntryLine(
                account_id=l.account_id,
                debit=l.debit,
                credit=l.credit,
                description=l.description or entry_in.description,
            )
            for l in entry_in.lines
        ]

        posted = self.repo.create_journal_entry(journal_entry, lines)
        return posted
