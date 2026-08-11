from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.customer import Customer
from app.models.kyc import CustomerKYC
from app.models.ornament import Ornament


class CustomerRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, customer_id: str) -> Optional[Customer]:
        return self.db.query(Customer).filter(Customer.id == customer_id).first()

    def get_all(self, skip: int = 0, limit: int = 100) -> List[Customer]:
        return self.db.query(Customer).offset(skip).limit(limit).all()

    def create(self, customer: Customer) -> Customer:
        self.db.add(customer)
        self.db.commit()
        self.db.refresh(customer)
        return customer

    def get_kyc(self, customer_id: str) -> Optional[CustomerKYC]:
        return self.db.query(CustomerKYC).filter(CustomerKYC.customer_id == customer_id).first()

    def get_jewellery(self, customer_id: str) -> List[Ornament]:
        return self.db.query(Ornament).filter(Ornament.customer_id == customer_id).all()
