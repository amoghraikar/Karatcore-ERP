import random
from sqlalchemy.orm import Session
from app.core.exceptions import ConflictError
from app.models.customer import Customer
from app.models.kyc import CustomerKYC
from app.repositories.customer_repo import CustomerRepository
from app.schemas.customer import CustomerCreate


class CustomerService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = CustomerRepository(db)

    def create_customer(self, customer_in: CustomerCreate) -> Customer:
        code = customer_in.id or customer_in.customer_code or f"KC-CUS-{random.randint(100100, 999999)}"
        phone_num = customer_in.phone or customer_in.mobile or ""
        
        existing = self.repo.get_by_id(code)
        if existing:
            existing.full_name = customer_in.full_name or existing.full_name
            if phone_num:
                existing.phone = phone_num
            if customer_in.email:
                existing.email = customer_in.email
            if customer_in.address:
                existing.address = customer_in.address
            self.db.commit()
            self.db.refresh(existing)
            return existing

        customer = Customer(
            id=code,
            customer_code=code,
            full_name=customer_in.full_name,
            phone=phone_num,
            email=customer_in.email,
            address=customer_in.address,
            status="ACTIVE",
            kyc_status="PENDING",
            pan_masked="",
            aadhaar_masked="",
        )
        created = self.repo.create(customer)

        # Initialize or retrieve KYC record in PENDING state
        kyc = self.db.query(CustomerKYC).filter(CustomerKYC.customer_id == created.id).first()
        if not kyc:
            kyc = CustomerKYC(
                customer_id=created.id,
                status="PENDING",
                verification_method="NOT_STARTED",
            )
            self.db.add(kyc)
            self.db.commit()

        return created
