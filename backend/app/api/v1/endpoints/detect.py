"""
POST /api/v1/detect — Lightweight sticker presence check.

Accepts a single camera frame (JPEG/PNG) and returns whether a valid
photochromic sticker was detected, with a confidence score.

This endpoint skips all MED/SPF calculation — it is designed to be called
rapidly (every ~1.5 s) from the scan screen's live preview loop so the UI
can give the user real-time feedback before committing to a full analysis.

Request body (multipart/form-data):
    image: UploadFile  — camera frame JPEG/PNG

Response (200):
    {
        "detected": bool,      # true if sticker found and confidence is sufficient
        "confidence": float,   # 0.0 – 1.0
        "reason": str | null   # null when detected, error code otherwise
    }
"""
import logging

from fastapi import APIRouter, File, UploadFile, status
from pydantic import BaseModel

from ....services.colorimetry_service import detect_sticker_presence
from ....utils.image_validator import validate_image

logger = logging.getLogger(__name__)
router = APIRouter()


class DetectResponse(BaseModel):
    detected: bool
    confidence: float
    reason: str | None = None


@router.post(
    "/detect",
    response_model=DetectResponse,
    summary="Lightweight sticker presence detection for live camera feedback",
    status_code=status.HTTP_200_OK,
)
async def detect_sticker(
    image: UploadFile = File(..., description="Camera preview frame (JPEG/PNG)"),
) -> DetectResponse:
    """
    Runs only the sticker-isolation step of the colorimetry pipeline.

    - No K-Means clustering.
    - No MED/SPF computation.
    - Returns within ~100–250 ms per frame on typical hardware.

    The endpoint always returns HTTP 200 — the `detected` flag carries the
    result so the mobile client never needs to handle unexpected error codes
    from this lightweight check.
    """
    try:
        image_bytes = await image.read()
    except Exception as exc:
        logger.warning("[Detect] Failed to read image bytes: %s", exc)
        return DetectResponse(detected=False, confidence=0.0, reason="read_error")

    # Validate image size / format to prevent abuse; soft-fail on rejection.
    try:
        validate_image(image_bytes)
    except ValueError as exc:
        logger.debug("[Detect] Image validation failed: %s", exc)
        return DetectResponse(detected=False, confidence=0.0, reason=str(exc))

    result = detect_sticker_presence(image_bytes)
    logger.debug(
        "[Detect] detected=%s confidence=%.2f reason=%s",
        result["detected"], result["confidence"], result.get("reason"),
    )
    return DetectResponse(**result)
