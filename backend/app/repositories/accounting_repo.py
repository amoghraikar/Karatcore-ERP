from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.accounting import AccountingAccount, JournalEntry, JournalEntryLine


class AccountingRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_account_by_code(self, code: str) -> Optional[AccountingAccount]:
        return self.db.query(AccountingAccount).filter(AccountingAccount.account_code == code).first()

    def get_all_accounts(self) -> List[AccountingAccount]:
        return self.db.query(AccountingAccount).all()

    def create_journal_entry(self, entry: JournalEntry, lines: List[JournalEntryLine]) -> JournalEntry:
        self.db.add(entry)
        self.db.flush()
        for line in lines:
            line.journal_entry_id = entry.id
            self.db.add(line)
        return entry
