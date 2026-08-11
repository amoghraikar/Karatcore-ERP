from datetime import datetime, timedelta, timezone
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base, get_db
from app.core.security import create_access_token, hash_password
import app.models  # Ensure all SQLAlchemy models are registered
from app.main import app as fastapi_app
from app.models.customer import Customer
from app.models.loan import Loan
from app.models.owner import Owner

TEST_DATABASE_URL = "sqlite:///./test_karatcore.db"

engine = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="session", autouse=True)
def setup_test_db():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()

    # Seed test Owner
    owner = Owner(
        full_name="Test Owner",
        email="testowner@karatcore.com",
        phone="+91 99999 99999",
        password_hash=hash_password("testpass123"),
    )
    db.add(owner)

    now = datetime.now(timezone.utc)

    # Seed Customer A
    cust_a = Customer(
        id="TEST-CUST-A",
        customer_code="TEST-CUST-A",
        full_name="Customer A",
        phone="+91 91111 11111",
        email="cust_a@test.com",
    )
    db.add(cust_a)

    loan_a = Loan(
        id="TEST-LOAN-A",
        loan_code="TEST-LOAN-A",
        customer_id="TEST-CUST-A",
        principal_amount=50000.0,
        interest_rate=12.0,
        start_date=now,
        maturity_date=now + timedelta(days=365),
        next_due_date=now + timedelta(days=30),
        outstanding_principal=50000.0,
    )
    db.add(loan_a)

    # Seed Customer B
    cust_b = Customer(
        id="TEST-CUST-B",
        customer_code="TEST-CUST-B",
        full_name="Customer B",
        phone="+91 92222 22222",
        email="cust_b@test.com",
    )
    db.add(cust_b)

    loan_b = Loan(
        id="TEST-LOAN-B",
        loan_code="TEST-LOAN-B",
        customer_id="TEST-CUST-B",
        principal_amount=75000.0,
        interest_rate=14.0,
        start_date=now,
        maturity_date=now + timedelta(days=365),
        next_due_date=now + timedelta(days=30),
        outstanding_principal=75000.0,
    )
    db.add(loan_b)

    db.commit()
    db.close()

    yield

    Base.metadata.drop_all(bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


fastapi_app.dependency_overrides[get_db] = override_get_db


@pytest.fixture
def client():
    return TestClient(fastapi_app)


@pytest.fixture
def owner_headers():
    token = create_access_token(subject="testowner@karatcore.com", user_type="owner")
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def customer_a_headers():
    token = create_access_token(subject="TEST-CUST-A", user_type="customer", customer_id="TEST-CUST-A")
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def customer_b_headers():
    token = create_access_token(subject="TEST-CUST-B", user_type="customer", customer_id="TEST-CUST-B")
    return {"Authorization": f"Bearer {token}"}
