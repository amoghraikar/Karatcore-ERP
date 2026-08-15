import os
import sys

# Ensure backend root is in python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import Base, engine
import app.models  # Import all SQLAlchemy models to register metadata

def reset_database():
    print("🧹 Cleaning and resetting live Supabase PostgreSQL Database...")
    try:
        print("  - Dropping all existing tables...")
        Base.metadata.drop_all(bind=engine)
        print("  ✓ All existing tables successfully dropped.")

        print("  - Creating fresh database schema tables...")
        Base.metadata.create_all(bind=engine)
        print("  ✓ Fresh database schema tables created successfully!")
        print("\n✨ Database is now 100% clean and ready for new Store Owner registration!")
    except Exception as e:
        print(f"❌ Error resetting database: {e}")
        sys.exit(1)

if __name__ == "__main__":
    reset_database()
