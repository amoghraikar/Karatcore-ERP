from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.core.config import settings

db_url = settings.DATABASE_URL.strip() if settings.DATABASE_URL else "sqlite:///./karatcore.db"

# If an HTTP/HTTPS API URL was mistakenly configured as DATABASE_URL, fall back to SQLite
if db_url.startswith("http://") or db_url.startswith("https://") or not db_url:
    print(f"⚠️ [DATABASE] Invalid DATABASE_URL scheme '{db_url}'. Falling back to SQLite: sqlite:///./karatcore.db", flush=True)
    db_url = "sqlite:///./karatcore.db"

# SQLAlchemy 2.0 compatibility: normalize postgres:// to postgresql://
if db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql://", 1)

# Configure SQLite fallback & PostgreSQL engine parameters
connect_args = {"check_same_thread": False} if db_url.startswith("sqlite") else {}

engine = create_engine(
    db_url,
    connect_args=connect_args,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db() -> Generator:
    """Dependency producing clean per-request database sessions."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
