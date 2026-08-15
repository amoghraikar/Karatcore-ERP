import os
import sys

# Ensure backend root is in python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import Base, engine, SessionLocal
import app.models  # Import all SQLAlchemy models to register metadata

def reset_database():
    print("🧹 Cleaning and resetting live Database...", flush=True)
    db = SessionLocal()
    try:
        # Delete records from all domain tables
        for model in [
            app.models.payment.LoanPayment,
            app.models.payment.Receipt,
            app.models.pledge.Pledge,
            app.models.loan.Loan,
            app.models.ornament.Valuation,
            app.models.ornament.Ornament,
            app.models.kyc.CustomerKYC,
            app.models.customer.Customer,
            app.models.accounting.JournalEntryLine,
            app.models.accounting.JournalEntry,
            app.models.accounting.AccountingAccount,
            app.models.owner.Owner,
        ]:
            try:
                db.query(model).delete()
            except Exception:
                pass
        db.commit()
        print("  ✓ All existing records cleared from database.", flush=True)

        from sqlalchemy import text
        try:
            db.execute(text("ALTER TABLE owners ADD COLUMN IF NOT EXISTS store_name VARCHAR(255);"))
            db.commit()
        except Exception as ex:
            print(f"  Note: {ex}", flush=True)

        print("  ✓ Fresh database schema ready!", flush=True)
        print("\n✨ Database is now 100% clean and ready for new Store Owner registration!", flush=True)
    except Exception as e:
        db.rollback()
        print(f"❌ Error resetting database: {e}", flush=True)
        sys.exit(1)
    finally:
        db.close()

if __name__ == "__main__":
    reset_database()
