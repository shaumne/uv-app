"""
Pydantic request models for the /analyze endpoint.

ambient_lux: lux reading from the device light sensor — used to
             correct white balance before HEX extraction.
skin_type:   Fitzpatrick scale 1–6.
spf:         Sunscreen protection factor (1 = no sunscreen).
"""
from pydantic import BaseModel, Field


class AnalyzeRequest(BaseModel):
    ambient_lux: float = Field(..., ge=0, description="Ambient light in lux")
    skin_type: int = Field(..., ge=1, le=6, description="Fitzpatrick skin type 1–6")
    spf: int = Field(default=1, ge=1, le=100, description="SPF factor applied")
