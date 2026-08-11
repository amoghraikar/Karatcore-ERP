from sqlalchemy import Column, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Ornament(BaseModel):
    __tablename__ = "ornaments"

    id = Column(String(50), primary_key=True, index=True)  # e.g. ORN-8821
    ornament_code = Column(String(50), unique=True, index=True, nullable=False)
    customer_id = Column(String(50), ForeignKey("customers.id"), nullable=True, index=True)
    name = Column(String(255), nullable=False)
    category = Column(String(100), nullable=False)  # Rings, Necklaces, Bangles
    metal_type = Column(String(50), nullable=False)  # Gold, Silver, Platinum
    purity = Column(String(50), nullable=False)  # 22K / 916, 24K
    gross_weight = Column(Float, nullable=False)
    stone_weight = Column(Float, default=0.0, nullable=False)
    net_weight = Column(Float, nullable=False)
    description = Column(String(500), default="", nullable=False)
    status = Column(String(50), default="PLEDGED", nullable=False, index=True)  # AVAILABLE, PLEDGED, RELEASED, SOLD

    customer = relationship("Customer", back_populates="ornaments")
    valuations = relationship("Valuation", back_populates="ornament")


class Valuation(BaseModel):
    __tablename__ = "valuations"

    id = Column(Integer, primary_key=True, index=True)
    ornament_id = Column(String(50), ForeignKey("ornaments.id"), nullable=False, index=True)
    metal_rate = Column(Float, nullable=False)
    gross_weight = Column(Float, nullable=False)
    net_weight = Column(Float, nullable=False)
    purity = Column(String(50), nullable=False)
    valuation_amount = Column(Float, nullable=False)
    valued_at = Column(String(100), nullable=False)
    notes = Column(String(500), default="", nullable=False)

    ornament = relationship("Ornament", back_populates="valuations")
