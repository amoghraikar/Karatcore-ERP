from typing import List, Optional
from pydantic import BaseModel, ConfigDict, field_validator


class JournalLineCreate(BaseModel):
    account_id: int
    debit: float = 0.0
    credit: float = 0.0
    description: Optional[str] = ""


class JournalEntryCreate(BaseModel):
    description: str
    lines: List[JournalLineCreate]
    reference_type: Optional[str] = None
    reference_id: Optional[str] = None


class JournalLineResponse(BaseModel):
    id: int
    account_id: int
    debit: float
    credit: float
    description: str

    model_config = ConfigDict(from_attributes=True)


class JournalEntryResponse(BaseModel):
    id: int
    entry_number: str
    description: str
    status: str
    lines: List[JournalLineResponse]

    model_config = ConfigDict(from_attributes=True)
