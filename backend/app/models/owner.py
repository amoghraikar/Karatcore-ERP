from sqlalchemy import Column, DateTime, Integer, String
from app.models.base import BaseModel


class Owner(BaseModel):
    __tablename__ = "owners"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    phone = Column(String(50), nullable=False)
    password_hash = Column(String(255), nullable=False)
    status = Column(String(50), default="ACTIVE", nullable=False)
    last_login_at = Column(DateTime, nullable=True)
