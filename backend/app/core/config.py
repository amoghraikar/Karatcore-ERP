from typing import List, Union
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    ENVIRONMENT: str = "development"
    APP_ENV: str = "development"
    PROJECT_NAME: str = "KaratCore ERP Backend"
    API_V1_STR: str = "/api/v1"

    # Database
    DATABASE_URL: str = "sqlite:///./karatcore.db"

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
