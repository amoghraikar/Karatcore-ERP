from sqlalchemy import Column, Integer, String
from app.models.base import BaseModel


class Document(BaseModel):
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(String(50), nullable=True, index=True)
    document_type = Column(String(100), nullable=False)  # KYC, LOAN_CONTRACT, RECEIPT
    related_entity_type = Column(String(50), nullable=True)
    related_entity_id = Column(String(50), nullable=True)
    storage_reference = Column(String(500), nullable=False)
    file_name = Column(String(255), nullable=False)
    mime_type = Column(String(100), nullable=False)
    file_size = Column(Integer, nullable=False)
