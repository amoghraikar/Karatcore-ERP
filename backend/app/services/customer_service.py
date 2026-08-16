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
        code = customer_in.customer_code or f"CUST-{random.randint(100, 999)}"
        existing = self.repo.get_by_id(code)
        if existing:
            raise ConflictError(f"Customer with code #{code} already exists.")

        customer = Customer(
            id=code,
            customer_code=code,
            full_name=customer_in.full_name,
            phone=customer_in.phone,
            email=customer_in.email,
            address=customer_in.address,
            status="ACTIVE",
            kyc_status="PENDING",
            pan_masked="",
            aadhaar_masked="",
        )
        created = self.repo.create(customer)

        # Initialize KYC record in PENDING state
        kyc = CustomerKYC(
            customer_id=created.id,
            status="PENDING",
            verification_method="NOT_STARTED",
        )
        self.db.add(kyc)
        self.db.commit()

        return created
