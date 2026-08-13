from typing import List, Union
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    ENVIRONMENT: str = "development"
    APP_ENV: str = "development"
    PROJECT_NAME: str = "KaratCore ERP Backend"
    API_V1_STR: str = "/api/v1"

    # Database (Supabase PostgreSQL / SQLite)
    DATABASE_URL: str = "sqlite:///./karatcore.db"

    # Supabase Integration
    SUPABASE_URL: str = ""
    SUPABASE_KEY: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""

    # JWT Security
    JWT_SECRET_KEY: str = "karatcore_super_secret_jwt_key_change_in_production_998214"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 480
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # CORS
    CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8080", "http://127.0.0.1:3000", "*"]

    # Storage & Integration Providers
    STORAGE_PROVIDER: str = "local"
    PAYMENT_PROVIDER: str = "MOCK"
    IDENTITY_PROVIDER: str = "MOCK"
    LOG_LEVEL: str = "INFO"

    # SMS Gateway Configuration (Twilio / Fast2SMS)
    SMS_PROVIDER: str = "twilio"  # twilio | fast2sms | mock
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_FROM_NUMBER: str = ""
    FAST2SMS_API_KEY: str = ""

    # SMTP Email Server Configuration
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_TLS: bool = True
    EMAILS_FROM_EMAIL: str = "notifications@karatcore.com"
    EMAILS_FROM_NAME: str = "KaratCore Security"

    @field_validator("JWT_SECRET_KEY")
    @classmethod
    def validate_jwt_secret_in_production(cls, v: str, info) -> str:
        # FAIL FAST in production if default secret is used
        app_env = info.data.get("APP_ENV", "development")
        if app_env == "production" and "change_in_production" in v:
            raise ValueError("CRITICAL SECURITY ERROR: Default JWT_SECRET_KEY cannot be used in production!")
        return v

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )


settings = Settings()
