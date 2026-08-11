import random
import uuid
from datetime import datetime, timezone
from typing import Optional
from sqlalchemy.orm import Session

from app.core.exceptions import AuthorizationError, BusinessRuleError, NotFoundError
from app.models.audit import AuditEvent
from app.models.kyc import CustomerKYC, KYCConsent, KYCDocument, KYCVerificationHistory, KYCVerificationSession
from app.models.notification import Notification
from app.repositories.customer_repo import CustomerRepository
from app.repositories.kyc_repo import KYCRepository
from app.schemas.kyc import KYCConsentRequest, KYCDocumentUploadRequest, KYCReviewAction
from app.services.identity_provider.mock_provider import MockIdentityVerificationProvider
from app.services.storage_service import StorageService


class KYCService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = KYCRepository(db)
        self.customer_repo = CustomerRepository(db)
        self.mock_provider = MockIdentityVerificationProvider()

    def get_or_create_kyc(self, customer_id: str, method: str = "MANUAL") -> CustomerKYC:
        kyc = self.repo.get_by_customer_id(customer_id)
        if not kyc:
            kyc = CustomerKYC(
                customer_id=customer_id,
                status="PENDING_CUSTOMER",
                verification_method=method,
            )
            kyc = self.repo.create_kyc(kyc)
            self._log_history(kyc.id, "CREATED", "CUSTOMER", customer_id, f"KYC record initialized with method {method}")
        return kyc

    def upload_document(self, customer_id: str, req: KYCDocumentUploadRequest) -> KYCDocument:
        # Server-side File Validation
        StorageService.validate_file_metadata(req.file_size, req.mime_type)

        kyc = self.get_or_create_kyc(customer_id)
        if kyc.status == "VERIFIED":
            raise BusinessRuleError("Cannot upload new documents to an already VERIFIED KYC record.")

        storage_ref = StorageService.generate_storage_reference(customer_id, req.document_type, req.file_name)

        doc = KYCDocument(
            kyc_id=kyc.id,
            document_type=req.document_type,
            masked_identifier=req.masked_identifier,
            storage_reference=storage_ref,
            file_name=req.file_name,
            mime_type=req.mime_type,
            file_size=req.file_size,
            status="SUBMITTED",
            uploaded_at=datetime.now(timezone.utc),
        )
        saved_doc = self.repo.add_document(doc)

        self._log_audit(customer_id, "DOCUMENT_UPLOADED", "KYC_DOCUMENT", str(saved_doc.id), {"document_type": req.document_type})
        return saved_doc

    def delete_document(self, customer_id: str, doc_id: int) -> None:
        doc = self.repo.get_document(doc_id)
        if not doc:
            raise NotFoundError("Document not found.")

        kyc = self.repo.get_by_id(doc.kyc_id)
        if not kyc or kyc.customer_id != customer_id:
            raise AuthorizationError("Access Restricted: You do not own this document.")

        if kyc.status == "VERIFIED":
            raise BusinessRuleError("Cannot delete documents from a VERIFIED KYC record.")

        self.repo.delete_document(doc)
        self._log_audit(customer_id, "DOCUMENT_DELETED", "KYC_DOCUMENT", str(doc_id))

    def record_consent(self, customer_id: str, req: KYCConsentRequest) -> KYCConsent:
        kyc = self.get_or_create_kyc(customer_id)
        ref_id = f"CONSENT-{uuid.uuid4().hex[:8].upper()}"

        consent = KYCConsent(
            customer_id=customer_id,
            kyc_id=kyc.id,
            consent_type=req.consent_type,
            consent_text_version=req.consent_text_version,
            consented_at=datetime.now(timezone.utc),
            consent_status="ACCEPTED",
            consent_reference=ref_id,
        )
        saved_consent = self.repo.add_consent(consent)
        self._log_history(kyc.id, "CONSENT_RECORDED", "CUSTOMER", customer_id, f"Recorded versioned consent {req.consent_text_version}")
        return saved_consent

    def submit_kyc(self, customer_id: str) -> CustomerKYC:
        kyc = self.repo.get_by_customer_id(customer_id)
        if not kyc or not kyc.documents:
            raise BusinessRuleError("At least one identity document must be uploaded prior to KYC submission.")

        if not kyc.consents:
            raise BusinessRuleError("Customer consent must be accepted prior to KYC submission.")

        kyc.status = "UNDER_REVIEW"
        updated = self.repo.update_kyc(kyc)

        # Notify Owner & Log History
        self._log_history(kyc.id, "SUBMITTED", "CUSTOMER", customer_id, "KYC submitted for Owner review")
        self._notify_owner(f"New KYC Submitted for Review: Customer #{customer_id}")
        return updated

    def create_digital_verification_session(self, customer_id: str) -> KYCVerificationSession:
        kyc = self.get_or_create_kyc(customer_id, method="DIGITAL")
        session_data = self.mock_provider.create_verification_session(customer_id, kyc.id)

        session = KYCVerificationSession(
            id=session_data["provider_session_id"],
            customer_id=customer_id,
            kyc_id=kyc.id,
            provider="DEMO_MOCK",
            provider_session_id=session_data["provider_session_id"],
            status="PENDING",
            created_at=session_data["created_at"],
            expires_at=session_data["expires_at"],
        )
        self.db.add(session)
        self.db.commit()

        # Automatically simulate completion in mock mode
        self.process_mock_digital_verification(session.id)
        return session

    def process_mock_digital_verification(self, session_id: str) -> None:
        session = self.db.query(KYCVerificationSession).filter(KYCVerificationSession.id == session_id).first()
        if not session:
            return

        res = self.mock_provider.get_verification_status(session.provider_session_id)
        if res["status"] == "VERIFIED":
            session.status = "VERIFIED"
            session.completed_at = datetime.now(timezone.utc)

            kyc = self.repo.get_by_id(session.kyc_id)
            if kyc:
                kyc.status = "VERIFIED"
                kyc.verified_at = datetime.now(timezone.utc)
                self.repo.update_kyc(kyc)

                # Update Customer KYC status
                customer = self.customer_repo.get_by_id(kyc.customer_id)
                if customer:
                    customer.kyc_status = "VERIFIED"
                    self.db.commit()

                self._log_history(kyc.id, "DIGITAL_VERIFIED", "SYSTEM", "MOCK_PROVIDER", "Simulated digital identity verification completed")
                self._notify_customer(kyc.customer_id, "Digital KYC Verification Successful", "Your digital identity verification has been completed successfully.")

    # --- OWNER REVIEW ACTIONS ---

    def approve_kyc(self, kyc_id: int, reviewer_name: str, action: KYCReviewAction) -> CustomerKYC:
        kyc = self.repo.get_by_id(kyc_id)
        if not kyc:
            raise NotFoundError("KYC record not found.")

        kyc.status = "VERIFIED"
        kyc.verified_at = datetime.now(timezone.utc)
        kyc.notes = action.reviewer_notes
        kyc.reverification_required = False

        # Update Customer status
        customer = self.customer_repo.get_by_id(kyc.customer_id)
        if customer:
            customer.kyc_status = "VERIFIED"

        updated = self.repo.update_kyc(kyc)

        self._log_history(kyc.id, "APPROVED", "OWNER", reviewer_name, f"Approved by owner. Notes: {action.reviewer_notes}")
        self._notify_customer(kyc.customer_id, "KYC Verification Approved!", "Your identity documents have been verified by KaratCore Store Owner.")
        return updated

    def reject_kyc(self, kyc_id: int, reviewer_name: str, action: KYCReviewAction) -> CustomerKYC:
        kyc = self.repo.get_by_id(kyc_id)
        if not kyc:
            raise NotFoundError("KYC record not found.")

        if not action.rejection_reason:
            raise BusinessRuleError("A structured rejection reason is required when rejecting KYC.")

        kyc.status = "REJECTED"
        kyc.rejection_reason = action.rejection_reason
        kyc.notes = action.reviewer_notes

        customer = self.customer_repo.get_by_id(kyc.customer_id)
        if customer:
            customer.kyc_status = "REJECTED"

        updated = self.repo.update_kyc(kyc)

        self._log_history(kyc.id, "REJECTED", "OWNER", reviewer_name, f"Rejected: {action.rejection_reason}")
        self._notify_customer(kyc.customer_id, "KYC Verification Update", f"Your submitted KYC requires attention: {action.rejection_reason}")
        return updated

    def request_reverification(self, kyc_id: int, reviewer_name: str, action: KYCReviewAction) -> CustomerKYC:
        kyc = self.repo.get_by_id(kyc_id)
        if not kyc:
            raise NotFoundError("KYC record not found.")

        kyc.status = "REVERIFICATION_REQUIRED"
        kyc.reverification_required = True
        kyc.notes = action.reviewer_notes

        updated = self.repo.update_kyc(kyc)

        self._log_history(kyc.id, "REVERIFICATION_REQUESTED", "OWNER", reviewer_name, f"Reverification requested. Notes: {action.reviewer_notes}")
        self._notify_customer(kyc.customer_id, "Action Required: Update KYC Documents", "Store Owner requested updated identity verification documents.")
        return updated

    # --- HELPERS ---

    def _log_history(self, kyc_id: int, action: str, actor_type: str, actor_id: str, notes: str) -> None:
        hist = KYCVerificationHistory(
            kyc_id=kyc_id,
            status=action,
            action=action,
            actor_type=actor_type,
            actor_id=actor_id,
            timestamp=datetime.now(timezone.utc),
            notes=notes,
        )
        self.repo.add_history(hist)

    def _log_audit(self, actor_id: str, action: str, entity_type: str, entity_id: str, metadata: Optional[dict] = None) -> None:
        audit = AuditEvent(
            actor_type="CUSTOMER",
            actor_id=actor_id,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            metadata_info=metadata,
        )
        self.db.add(audit)
        self.db.commit()

    def _notify_customer(self, customer_id: str, title: str, message: str) -> None:
        notif = Notification(
            id=f"NOTIF-{random.randint(10000, 99999)}",
            recipient_type="CUSTOMER",
            recipient_id=customer_id,
            title=title,
            message=message,
            category="KYC",
            priority="HIGH",
            status="UNREAD",
        )
        self.db.add(notif)
        self.db.commit()

    def _notify_owner(self, title: str) -> None:
        notif = Notification(
            id=f"NOTIF-{random.randint(10000, 99999)}",
            recipient_type="OWNER",
            recipient_id="OWNER",
            title=title,
            message=title,
            category="KYC",
            priority="MEDIUM",
            status="UNREAD",
        )
        self.db.add(notif)
        self.db.commit()
