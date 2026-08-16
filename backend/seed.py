import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.core.database import Base, SessionLocal, engine
from app.core.security import hash_password
from app.models.accounting import AccountingAccount
from app.models.owner import Owner


def seed_database():
    print("🌱 Initializing KaratCore Database Seed Data...")
    from app.core.config import settings
    if settings.DATABASE_URL.startswith("sqlite"):
        Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # 1. Seed Owner (Required for Authentication)
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

        # 2. Seed Accounting Ledger Accounts
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
        print("✅ Database Seed Completed Successfully!")

    except Exception as e:
        db.rollback()
        print(f"❌ Seed failed: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
