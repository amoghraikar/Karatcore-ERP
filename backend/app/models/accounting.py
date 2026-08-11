from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class AccountingAccount(BaseModel):
    __tablename__ = "accounting_accounts"

    id = Column(Integer, primary_key=True, index=True)
    account_code = Column(String(50), unique=True, index=True, nullable=False)
    name = Column(String(255), nullable=False)
    account_type = Column(String(50), nullable=False)  # ASSET, LIABILITY, EQUITY, INCOME, EXPENSE
    parent_id = Column(Integer, ForeignKey("accounting_accounts.id"), nullable=True)
    status = Column(String(50), default="ACTIVE", nullable=False)


class JournalEntry(BaseModel):
    __tablename__ = "journal_entries"

    id = Column(Integer, primary_key=True, index=True)
    entry_number = Column(String(50), unique=True, index=True, nullable=False)
    entry_date = Column(DateTime, nullable=False)
    description = Column(String(500), nullable=False)
    reference_type = Column(String(50), nullable=True)  # PAYMENT, DISBURSEMENT, EXPENSE
    reference_id = Column(String(50), nullable=True)
    status = Column(String(50), default="POSTED", nullable=False)  # DRAFT, POSTED

    lines = relationship("JournalEntryLine", back_populates="journal_entry")


class JournalEntryLine(BaseModel):
    __tablename__ = "journal_entry_lines"

    id = Column(Integer, primary_key=True, index=True)
    journal_entry_id = Column(Integer, ForeignKey("journal_entries.id"), nullable=False, index=True)
    account_id = Column(Integer, ForeignKey("accounting_accounts.id"), nullable=False, index=True)

    # Financial Precision using Numeric(12, 2)
    debit = Column(Numeric(12, 2), default=0.00, nullable=False)
    credit = Column(Numeric(12, 2), default=0.00, nullable=False)
    description = Column(String(255), default="", nullable=False)

    journal_entry = relationship("JournalEntry", back_populates="lines")
    account = relationship("AccountingAccount")


class Expense(BaseModel):
    __tablename__ = "expenses"

    id = Column(Integer, primary_key=True, index=True)
    account_id = Column(Integer, ForeignKey("accounting_accounts.id"), nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    date = Column(DateTime, nullable=False)
    description = Column(String(500), nullable=False)
    reference = Column(String(255), nullable=True)


class Income(BaseModel):
    __tablename__ = "income"

    id = Column(Integer, primary_key=True, index=True)
    account_id = Column(Integer, ForeignKey("accounting_accounts.id"), nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    date = Column(DateTime, nullable=False)
    description = Column(String(500), nullable=False)
    reference = Column(String(255), nullable=True)
