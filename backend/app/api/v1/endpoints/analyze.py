"""
POST /api/v1/analyze — Sticker UV analysis endpoint.

Accepts a multipart/form-data request:
    image                 : JPEG/PNG camera capture of the photochromic sticker
    ambient_lux           : Ambient light sensor reading (float)
    skin_type             : Fitzpatrick skin type 1–6 (int)
    spf                   : Sunscreen SPF factor (int, default 1)
    hours_since_application: Hours since sunscreen was applied (float, default 0)
    cumulative_dose_jm2   : UV dose already received today in J/m² (float, default 0)
    uv_index              : Current real-time UV Index (float, default 5.0)

Returns [AnalyzeResponse] — full merged colorimetry + dermatology payload.
"""
import logging

from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status

from ....models.response_models import AnalyzeResponse
from ....services.colorimetry_service import extract_sticker_data
from ....services.med_calculator import calculate_uv_risk, uv_percent_to_dose_jm2
from ....utils.image_validator import validate_image

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post(
    "/analyze",
    response_model=AnalyzeResponse,
    summary="Analyse photochromic sticker and compute UV dose",
    status_code=status.HTTP_200_OK,
    responses={
        422: {"description": "Image validation or sticker detection failure"},
        500: {"description": "Internal image processing error"},
    },
)
async def analyze_sticker(
    image: UploadFile = File(..., description="Camera image of the UV sticker patch"),
    ambient_lux: float = Form(..., ge=0, description="Ambient light in lux"),
    skin_type: int = Form(..., ge=1, le=6, description="Fitzpatrick skin type"),
    spf: float = Form(default=1.0, ge=1, le=100, description="SPF factor"),
    hours_since_application: float = Form(default=0.0, ge=0, description="Hours since sunscreen applied"),
    cumulative_dose_jm2: float = Form(default=0.0, ge=0, description="Cumulative UV dose today (J/m²)"),
    uv_index: float = Form(default=5.0, ge=0, description="Current UV Index"),
) -> AnalyzeResponse:
    """
    Full analysis pipeline:

    1. Validate uploaded image (size, format, dimensions).
    2. Extract sticker hex colour and UV% via OpenCV colorimetry.
    3. Convert UV% → J/m² dose increment for the user's skin type.
    4. Accumulate with today's cumulative dose.
    5. Run MED/SPF dermatology calculation.
    6. Return merged JSON response.
    """
    # ── Step 1: Read and validate image ──────────────────────────────────────
    try:
        image_bytes = await image.read()
    except Exception as exc:
        logger.error("Failed to read uploaded image: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Could not read the uploaded image.",
        ) from exc

    try:
        validate_image(image_bytes)
    except ValueError as exc:
        logger.warning("Image validation failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        ) from exc

    # ── Step 2: Colorimetry — hex + UV% ───────────────────────────────────────
    try:
        hex_color, uv_percent = extract_sticker_data(image_bytes, ambient_lux)
    except ValueError as exc:
        err_str = str(exc)
        logger.warning("Colorimetry failed: %s", err_str)
        # Map known error codes to specific 422 detail messages
        if "sticker_not_detected" in err_str:
            detail = "Sticker not detected. Ensure the sticker is inside the frame."
        elif "sticker_too_small" in err_str:
            detail = "Sticker area too small. Hold the camera closer."
        elif "too dark" in err_str:
            detail = "Image too dark. Move to better lighting and retry."
        else:
            detail = f"Sticker colour extraction failed: {err_str}"
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=detail,
        ) from exc
    except Exception as exc:
        logger.exception("Unexpected error during colour extraction.")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal image processing error.",
        ) from exc

    # ── Step 3: Convert UV% → J/m² and accumulate ────────────────────────────
    try:
        scan_dose_jm2 = uv_percent_to_dose_jm2(uv_percent, skin_type)
        updated_cumulative = cumulative_dose_jm2 + scan_dose_jm2
    except ValueError as exc:
        logger.error("Dose conversion failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        ) from exc

    # ── Step 4: MED / SPF calculation ─────────────────────────────────────────
    try:
        risk_payload = calculate_uv_risk(
            fitzpatrick=skin_type,
            spf=spf,
            hours_since_application=hours_since_application,
            cumulative_dose_jm2=updated_cumulative,
            uv_index=uv_index,
        )
    except ValueError as exc:
        logger.error("MED calculation failed: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        ) from exc

    return AnalyzeResponse(
        hex_color=hex_color,
        uv_percent=uv_percent,
        **risk_payload,
    )
