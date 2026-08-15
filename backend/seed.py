import os
import sys
from datetime import datetime, timedelta, timezone

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.core.database import Base, SessionLocal, engine
from app.core.security import hash_password
from app.models.accounting import AccountingAccount, JournalEntry, JournalEntryLine
from app.models.customer import Customer
from app.models.kyc import CustomerKYC
from app.models.loan import Loan
from app.models.payment import LoanPayment, Receipt
from app.models.ornament import Ornament, Valuation
from app.models.owner import Owner
from app.models.pledge import Pledge


def seed_database():
    print("🌱 Initializing KaratCore Database Seed Data...")
    from app.core.config import settings
    if settings.DATABASE_URL.startswith("sqlite"):
        Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # 1. Seed Owner
        if not db.query(Owner).filter(Owner.email == "owner@karatcore.com").first():
            owner = Owner(
                full_name="Store Owner",
                email="owner@karatcore.com",
                phone="+91 98200 00000",
                password_hash=hash_password("password123"),
                status="ACTIVE",
            )
            db.add(owner)
            print("  ✓ Created Owner: Store Owner (owner@karatcore.com / password123)")

        # 2. Seed Customers (Customer A & Customer B)
        cust_a = db.query(Customer).filter(Customer.id == "KC-CUS-000101").first()
        if not cust_a:
            cust_a = Customer(
                id="KC-CUS-000101",
                customer_code="KC-CUS-000101",
                full_name="Rahul Sharma",
                phone="+91 98201 12345",
                email="rahul.sharma@example.com",
                address="Flat 402, Sunshine Heights, M.G. Road, Mumbai, Maharashtra - 400001",
                status="ACTIVE",
                kyc_status="VERIFIED",
                pan_masked="ABCPS****F",
                aadhaar_masked="XXXX-XXXX-8821",
            )
            db.add(cust_a)

            kyc_a = CustomerKYC(
                customer_id=cust_a.id,
                status="VERIFIED",
                verification_method="MANUAL_STORE_REVIEW",
                verified_at=datetime.now(timezone.utc),
            )
            db.add(kyc_a)
            print("  ✓ Created Customer A: Rahul Sharma (KC-CUS-000101)")

        cust_b = db.query(Customer).filter(Customer.id == "CUST-002").first()
        if not cust_b:
            cust_b = Customer(
                id="CUST-002",
                customer_code="CUST-002",
                full_name="Sunita Devi",
                phone="+91 98211 54321",
                email="sunita.devi@example.com",
                address="House No 12, Park Street, Pune, Maharashtra - 411001",
                status="ACTIVE",
                kyc_status="VERIFIED",
                pan_masked="XYZPS****K",
                aadhaar_masked="XXXX-XXXX-1142",
            )
            db.add(cust_b)

            kyc_b = CustomerKYC(
                customer_id=cust_b.id,
                status="VERIFIED",
                verification_method="MANUAL_STORE_REVIEW",
                verified_at=datetime.now(timezone.utc),
            )
            db.add(kyc_b)
            print("  ✓ Created Customer B: Sunita Devi (CUST-002)")

        db.commit()

        # 3. Seed Accounting Accounts
        accounts = [
            (1, "1001", "Cash & Bank Balance", "ASSET"),
            (2, "1100", "Gold Loan Principal Receivables", "ASSET"),
            (3, "4001", "Interest Income on Gold Loans", "INCOME"),
            (4, "2001", "Customer Safe Custody Deposits", "LIABILITY"),
        ]
        for acc_id, code, name, acc_type in accounts:
            if not db.query(AccountingAccount).filter(AccountingAccount.id == acc_id).first():
                db.add(AccountingAccount(id=acc_id, account_code=code, name=name, account_type=acc_type))
        db.commit()

        # 4. Seed Ornaments & Loans for Customer A
        if not db.query(Loan).filter(Loan.id == "KC-LN-9042").first():
            orn1 = Ornament(
                id="ORN-8821",
                ornament_code="ORN-8821",
                customer_id="KC-CUS-000101",
                name="22K Gold Necklace with Pendant",
                category="Necklaces",
                metal_type="Gold",
                purity="22K / 916",
                gross_weight=42.5,
                stone_weight=2.0,
                net_weight=40.5,
                status="PLEDGED",
            )
            db.add(orn1)

            val1 = Valuation(
                ornament_id="ORN-8821",
                metal_rate=6850.0,
                gross_weight=42.5,
                net_weight=40.5,
                purity="22K / 916",
                valuation_amount=254000.0,
                valued_at="2025-10-14",
            )
            db.add(val1)

            plg1 = Pledge(
                id="PLG-9042",
                pledge_code="PLG-9042",
                customer_id="KC-CUS-000101",
                loan_id="KC-LN-9042",
                pledge_date=datetime(2025, 10, 15, tzinfo=timezone.utc),
                status="ACTIVE",
            )
            db.add(plg1)

            loan1 = Loan(
                id="KC-LN-9042",
                loan_code="KC-LN-9042",
                customer_id="KC-CUS-000101",
                pledge_id="PLG-9042",
                principal_amount=180000.0,
                interest_rate=14.5,
                interest_type="SIMPLE",
                start_date=datetime(2025, 10, 15, tzinfo=timezone.utc),
                maturity_date=datetime(2026, 10, 15, tzinfo=timezone.utc),
                next_due_date=datetime(2026, 8, 25, tzinfo=timezone.utc),
                status="ACTIVE",
                outstanding_principal=180000.0,
                outstanding_interest=2175.0,
            )
            db.add(loan1)
            print("  ✓ Created Loan #KC-LN-9042 for Rahul Sharma")

        # 5. Seed Loan for Customer B
        if not db.query(Loan).filter(Loan.id == "KC-LN-00115").first():
            orn2 = Ornament(
                id="ORN-9901",
                ornament_code="ORN-9901",
                customer_id="CUST-002",
                name="Silver Bullion Bar 500g",
                category="Bullion Bars",
                metal_type="Silver",
                purity="Silver 999",
                gross_weight=500.0,
                stone_weight=0.0,
                net_weight=500.0,
                status="PLEDGED",
            )
            db.add(orn2)

            loan2 = Loan(
                id="KC-LN-00115",
                loan_code="KC-LN-00115",
                customer_id="CUST-002",
                principal_amount=45000.0,
                interest_rate=12.0,
                interest_type="SIMPLE",
                start_date=datetime(2026, 1, 10, tzinfo=timezone.utc),
                maturity_date=datetime(2027, 1, 10, tzinfo=timezone.utc),
                next_due_date=datetime(2026, 9, 10, tzinfo=timezone.utc),
                status="ACTIVE",
                outstanding_principal=45000.0,
                outstanding_interest=450.0,
            )
            db.add(loan2)
            print("  ✓ Created Loan #KC-LN-00115 for Sunita Devi")

        db.commit()
        print("✅ Database Seed Completed Successfully!")

    except Exception as e:
        db.rollback()
        print(f"❌ Seed failed: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
