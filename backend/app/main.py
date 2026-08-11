from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes.accounting import router as accounting_router
from app.api.routes.auth import router as auth_router
from app.api.routes.customer_kyc import router as customer_kyc_router
from app.api.routes.customer_payments import router as customer_payments_router
from app.api.routes.customer_portal import router as customer_portal_router
from app.api.routes.customers import router as customer_router
from app.api.routes.diagnostics import router as diagnostics_router
from app.api.routes.health import router as health_router
from app.api.routes.kyc import router as owner_kyc_router
from app.api.routes.loans import router as loan_router
from app.api.routes.payments import router as payment_router
from app.api.routes.webhooks import router as webhook_router
from app.core.config import settings
from app.core.middleware import RequestIDMiddleware, SecurityHeadersMiddleware
import app.models  # Register all declarative models
from app.core.database import Base, engine

# Ensure declarative models are created
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Register Custom Security & Correlation Middlewares
app.add_middleware(RequestIDMiddleware)
app.add_middleware(SecurityHeadersMiddleware)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Health & Diagnostics
app.include_router(health_router)
app.include_router(diagnostics_router, prefix=settings.API_V1_STR)

# Include API Routers under /api/v1
app.include_router(auth_router, prefix=settings.API_V1_STR)
app.include_router(customer_router, prefix=settings.API_V1_STR)
app.include_router(loan_router, prefix=settings.API_V1_STR)
app.include_router(payment_router, prefix=settings.API_V1_STR)
app.include_router(accounting_router, prefix=settings.API_V1_STR)
app.include_router(owner_kyc_router, prefix=settings.API_V1_STR)
app.include_router(webhook_router, prefix=settings.API_V1_STR)
app.include_router(customer_portal_router, prefix=settings.API_V1_STR)
app.include_router(customer_kyc_router, prefix=settings.API_V1_STR)
app.include_router(customer_payments_router, prefix=settings.API_V1_STR)
