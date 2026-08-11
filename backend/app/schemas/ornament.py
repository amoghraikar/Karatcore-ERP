from typing import Optional
from pydantic import BaseModel, ConfigDict


class OrnamentBase(BaseModel):
    name: str
    category: str
    metal_type: str
    purity: str
    gross_weight: float
    stone_weight: float = 0.0
    net_weight: float
    description: Optional[str] = ""


class OrnamentCreate(OrnamentBase):
    customer_id: Optional[str] = None


class OrnamentResponse(OrnamentBase):
    id: str
    ornament_code: str
    customer_id: Optional[str] = None
    status: str

    model_config = ConfigDict(from_attributes=True)
