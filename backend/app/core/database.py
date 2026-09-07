from typing import Generator
from sqlalchemy import create_engine, event
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
is_sqlite = db_url.startswith("sqlite")
connect_args = {"check_same_thread": False, "timeout": 30} if is_sqlite else {}

engine_kwargs = {
    "connect_args": connect_args,
    "pool_pre_ping": True,
}

if not is_sqlite:
    engine_kwargs.update({
        "pool_size": 25,
        "max_overflow": 50,
        "pool_recycle": 300,
        "pool_timeout": 30,
    })

engine = create_engine(db_url, **engine_kwargs)

# Optimize SQLite for ultra-high concurrency and sub-millisecond writes using WAL mode
if is_sqlite:
    @event.listens_for(engine, "connect")
    def set_sqlite_pragma(dbapi_connection, connection_record):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA journal_mode=WAL")
        cursor.execute("PRAGMA synchronous=NORMAL")
        cursor.execute("PRAGMA cache_size=-64000")  # 64MB RAM page cache
        cursor.execute("PRAGMA temp_store=MEMORY")
        cursor.execute("PRAGMA busy_timeout=15000") # Auto-wait up to 15s instead of instant lock error
        cursor.close()

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db() -> Generator:
    """Dependency producing clean per-request database sessions."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
