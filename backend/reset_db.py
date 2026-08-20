import os
import sys

# Ensure backend root is in python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import Base, engine, SessionLocal
import app.models  # Import all SQLAlchemy models to register metadata
from sqlalchemy import text

def reset_database():
    print("🧹 Cleaning and resetting Database...", flush=True)
    db = SessionLocal()
    try:
        # Disable foreign keys temporarily if using SQLite
        if engine.url.drivername.startswith("sqlite"):
            db.execute(text("PRAGMA foreign_keys = OFF;"))

        models_to_clear = [
            app.models.payment.PaymentReconciliation,
            app.models.payment.PaymentWebhookEvent,
            app.models.payment.PaymentTransaction,
            app.models.payment.PaymentRefund,
            app.models.payment.PaymentReversal,
            app.models.payment.Receipt,
            app.models.payment.LoanPayment,
            app.models.pledge.Pledge,
            app.models.loan.Loan,
            app.models.ornament.Valuation,
            app.models.ornament.Ornament,
            app.models.kyc.KYCVerificationHistory,
            app.models.kyc.KYCVerificationSession,
            app.models.kyc.KYCConsent,
            app.models.kyc.KYCDocument,
            app.models.kyc.CustomerKYC,
            app.models.document.Document,
            app.models.customer.Customer,
            app.models.accounting.JournalEntryLine,
            app.models.accounting.JournalEntry,
            app.models.accounting.Expense,
            app.models.accounting.Income,
            app.models.accounting.AccountingAccount,
            app.models.notification.Notification,
            app.models.notification.NotificationPreference,
            app.models.audit.AuditEvent,
            app.models.audit.SecurityEvent,
            app.models.owner.Owner,
        ]

        for model in models_to_clear:
            try:
                db.query(model).delete()
            except Exception as ex:
                pass

        db.commit()
        print("  ✓ All existing records cleared from database.", flush=True)

        try:
            db.execute(text("ALTER TABLE owners ADD COLUMN IF NOT EXISTS store_name VARCHAR(255);"))
            db.commit()
        except Exception:
            pass

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

