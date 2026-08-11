import os
import uuid
from app.core.exceptions import BusinessRuleError

MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024  # 10 MB limit
ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
    "application/pdf",
}


class StorageService:
    @staticmethod
    def validate_file_metadata(file_size: int, mime_type: str) -> None:
        if file_size > MAX_FILE_SIZE_BYTES:
            raise BusinessRuleError("File size exceeds maximum allowed 10 MB limit.")

        if mime_type.lower() not in ALLOWED_MIME_TYPES:
            raise BusinessRuleError(f"Unsupported file MIME type '{mime_type}'. Supported: JPEG, PNG, WEBP, PDF.")

    @staticmethod
    def generate_storage_reference(customer_id: str, document_type: str, file_name: str) -> str:
        safe_ext = os.path.splitext(file_name)[1].lower() or ".bin"
        random_id = str(uuid.uuid4())
        return f"/storage/kyc/{customer_id}/{document_type.lower()}_{random_id}{safe_ext}"
