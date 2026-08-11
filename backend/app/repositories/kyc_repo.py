from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.kyc import CustomerKYC, KYCConsent, KYCDocument, KYCVerificationHistory, KYCVerificationSession


class KYCRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_customer_id(self, customer_id: str) -> Optional[CustomerKYC]:
        return self.db.query(CustomerKYC).filter(CustomerKYC.customer_id == customer_id).first()

    def get_by_id(self, kyc_id: int) -> Optional[CustomerKYC]:
        return self.db.query(CustomerKYC).filter(CustomerKYC.id == kyc_id).first()

    def get_all(
        self,
        status: Optional[str] = None,
        method: Optional[str] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[CustomerKYC]:
        query = self.db.query(CustomerKYC)
        if status:
            query = query.filter(CustomerKYC.status == status)
        if method:
            query = query.filter(CustomerKYC.verification_method == method)
        return query.offset(skip).limit(limit).all()

    def create_kyc(self, kyc: CustomerKYC) -> CustomerKYC:
        self.db.add(kyc)
        self.db.commit()
        self.db.refresh(kyc)
        return kyc

    def update_kyc(self, kyc: CustomerKYC) -> CustomerKYC:
        self.db.commit()
        self.db.refresh(kyc)
        return kyc

    def add_document(self, doc: KYCDocument) -> KYCDocument:
        self.db.add(doc)
        self.db.commit()
        self.db.refresh(doc)
        return doc

    def get_document(self, doc_id: int) -> Optional[KYCDocument]:
        return self.db.query(KYCDocument).filter(KYCDocument.id == doc_id).first()

    def delete_document(self, doc: KYCDocument) -> None:
        self.db.delete(doc)
        self.db.commit()

    def add_consent(self, consent: KYCConsent) -> KYCConsent:
        self.db.add(consent)
        self.db.commit()
        self.db.refresh(consent)
        return consent

    def add_history(self, history: KYCVerificationHistory) -> KYCVerificationHistory:
        self.db.add(history)
        self.db.commit()
        return history
