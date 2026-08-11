# KaratCore ERP — Backend & Database Architecture

Production-ready Python/FastAPI/PostgreSQL backend foundation for **KaratCore ERP**.

## Technology Stack
- **Language**: Python 3.12+
- **Framework**: FastAPI
- **Database**: PostgreSQL (SQLAlchemy 2.x ORM, Alembic Migrations, SQLite dev fallback)
- **Validation**: Pydantic v2
- **Security**: JWT tokens, bcrypt/Argon2 password hashing
- **Testing**: pytest, httpx

---

## Setup & Execution

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Environment
Copy `.env.example` to `.env` and set parameters:
```bash
cp .env.example .env
```

### 3. Run Database Migrations & Seed Data
```bash
alembic upgrade head
python seed.py
```

### 4. Start Backend Server
```bash
uvicorn app.main:app --reload --port 8000
```
Interactive OpenAPI Documentation will be available at:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

### 5. Run Automated Pytest Suite
```bash
pytest -v
```

---

## Security & Customer Data Isolation
1. **Single Owner Model**: Owner endpoints (`/api/v1/...`) require `get_current_owner` dependency.
2. **Customer Data Isolation**: Customer endpoints (`/api/v1/customer/...`) require `get_current_customer` dependency and strictly enforce `authenticated_customer.id == resource.customer_id`. Attempting to access another customer's resource returns `404 Not Found` with zero data leakage.
3. **Double-Entry Accounting Rule**: `AccountingService` strictly validates `sum(debit) == sum(credit)` on every posted journal entry.
