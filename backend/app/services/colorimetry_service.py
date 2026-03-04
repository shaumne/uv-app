"""
Colorimetry service — OpenCV + scikit-learn UV sticker colour extraction.

Pipeline (matches ComputerVision_Colorimetry skill specification):
1. Decode raw image bytes into a NumPy/BGR array.
2. Apply LAB-space Grey-World white balance correction.
3. Isolate the sticker patch via HSV masking + multi-factor contour scoring.
4. Extract dominant colour from ONLY the pixels inside the sticker contour
   (not the full bounding rectangle) using scikit-learn K-Means (k=4).
   Select the cluster with highest chroma×count weight — the photochromic
   indicator dye — instead of blindly taking the largest cluster.
5. Map dominant colour to UV% via LAB L* perceptual interpolation (scipy).
6. Return hex string + uv_percent.

Required packages: opencv-python-headless, scikit-learn, scipy, numpy

Design decisions / key changes from prior version:
- pale_mask (S=25-59) was replaced with a hue-restricted warm-orange band to
  stop false-positive fires on walls, paper, skin and other neutral surfaces.
- K-Means now receives only masked contour pixels (not the entire bounding
  rectangle), eliminating background dilution that caused medium doses to
  appear lighter and skew the UV% toward 0.
- Cluster selection switches from "largest count" to "highest chroma×count"
  so the photochromic dye cluster wins over background white/grey clusters.
- All internal functions now crash-safe: minimum pixel guards prevent sklearn
  from throwing when the candidate ROI has fewer than k×10 pixels.
"""
import logging
import math

import cv2
import numpy as np
from scipy.interpolate import interp1d
from sklearn.cluster import KMeans

logger = logging.getLogger(__name__)

# ── UV calibration curve ───────────────────────────────────────────────────────
# Maps LAB L* values (CIE 0-100 scale) to cumulative UV MED percentage.
#
# Calibration data: photochromic orange-brown dye; update after each batch.
# Midpoints at L*=68 and L*=38 added for better discrimination in the
# medium (25-50%) and medium-high (50-75%) exposure ranges.
_CALIBRATION: list[tuple[float, float]] = [
    (92.0,   0.0),   # fresh / unexposed  — near-white
    (78.0,  10.0),   # very light tint
    (68.0,  25.0),   # pale orange
    (55.0,  50.0),   # orange
    (42.0,  70.0),   # dark orange  ← midpoint added
    (30.0,  85.0),   # orange-brown
    (18.0, 100.0),   # very dark brown / fully exposed
]
_L_VALS, _UV_VALS = zip(*_CALIBRATION)
_UV_CURVE = interp1d(_L_VALS, _UV_VALS, kind="linear", fill_value="extrapolate")

# ── Sticker detection thresholds ───────────────────────────────────────────────

# Minimum sticker contour area in pixels².
_MIN_STICKER_AREA_PX2 = 1_200

# Sticker must occupy 1 %–30 % of total image area.
_MAX_STICKER_AREA_FRACTION = 0.30
_MIN_STICKER_AREA_FRACTION = 0.010

# Aspect ratio w/h.  Stickers are square or circular.
_MIN_ASPECT_RATIO = 0.55
_MAX_ASPECT_RATIO = 1.82

# Compactness = 4π × A / P².  Raised to 0.38 to reject elongated blobs.
_MIN_COMPACTNESS = 0.38

# Fill ratio: contour area / bounding-rect area.  Raised to 0.55.
_MIN_FILL_RATIO = 0.55

# Confidence score required for "detected" verdict.  Raised to 0.55.
_DETECTION_CONFIDENCE_THRESHOLD = 0.55

# Minimum mean LAB L* value; below this the image is too dark to analyse.
_MIN_LIGHTNESS = 20.0

# Minimum pixel count inside a contour required for K-Means.
# Prevents sklearn from crashing when a very small contour passes scoring.
_MIN_CONTOUR_PIXELS = 150

# Minimum mean HSV saturation of the extracted ROI pixels.
# Lowered to 8 so that lightly-exposed (pale orange) and near-fresh stickers
# are accepted.  Shape geometry (compactness, fill, aspect) guards against
# neutral walls/skin that might also have very low saturation.
_MIN_ROI_SATURATION = 8


# ── Public API ────────────────────────────────────────────────────────────────

def extract_sticker_data(
    image_bytes: bytes,
    ambient_lux: float,
) -> tuple[str, float]:
    """
    Full colorimetry pipeline: image bytes → (hex_color, uv_percent).

    Args:
        image_bytes: Raw JPEG/PNG bytes from the mobile camera.
        ambient_lux: Ambient light sensor reading in lux (used for
                     low-light detection; white balance uses the LAB
                     grey-world algorithm independently).

    Returns:
        Tuple of (hex_color: str, uv_percent: float).
        hex_color is in '#RRGGBB' format.
        uv_percent is in range 0.0–100.0 (clamped).

    Raises:
        ValueError: Descriptive code string for client feedback.
    """
    image = _decode_image(image_bytes)
    _check_lightness(image)
    balanced = _white_balance_lab(image)
    roi_pixels = _isolate_sticker_pixels(balanced)
    hex_color = _dominant_hex_kmeans(roi_pixels)
    uv_percent = _hex_to_uv_percent(hex_color)

    logger.info(
        "[Colorimetry] lux=%.1f hex=%s uv_pct=%.1f",
        ambient_lux,
        hex_color,
        uv_percent,
    )
    return hex_color, uv_percent


def detect_sticker_presence(image_bytes: bytes) -> dict:
    """
    Lightweight sticker presence check — no MED calculation, no K-Means.

    Returns:
        dict with keys:
            detected (bool): True if a valid sticker patch was found.
            confidence (float): 0.0–1.0 detection confidence score.
            reason (str | None): Human-readable rejection reason if not detected.

    Never raises — all exceptions are caught and returned as not-detected.
    """
    try:
        image = _decode_image(image_bytes)
        _check_lightness(image)
        balanced = _white_balance_lab(image)
        contour, confidence = _find_best_sticker_contour(balanced)
        if contour is None:
            return {"detected": False, "confidence": 0.0, "reason": "sticker_not_detected"}
        if confidence < _DETECTION_CONFIDENCE_THRESHOLD:
            return {
                "detected": False,
                "confidence": round(confidence, 2),
                "reason": "low_confidence",
            }
        return {"detected": True, "confidence": round(confidence, 2), "reason": None}
    except ValueError as exc:
        reason = str(exc)
        logger.debug("[Detect] Not detected: %s", reason)
        return {"detected": False, "confidence": 0.0, "reason": reason}
    except Exception as exc:
        logger.warning("[Detect] Unexpected error: %s", exc)
        return {"detected": False, "confidence": 0.0, "reason": "processing_error"}


# ── Step 1 — Image decode ─────────────────────────────────────────────────────

def _decode_image(image_bytes: bytes) -> np.ndarray:
    """Decodes raw bytes into a BGR NumPy array (OpenCV native format)."""
    buffer = np.frombuffer(image_bytes, dtype=np.uint8)
    image = cv2.imdecode(buffer, cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError("Image decoding failed — unsupported format or corrupt data.")
    return image


# ── Step 1b — Darkness check ──────────────────────────────────────────────────

def _check_lightness(image: np.ndarray) -> None:
    """
    Rejects images that are too dark for reliable colour analysis.

    OpenCV encodes LAB L* as 0-255; dividing by 2.55 yields the
    perceptual 0-100 scale (CIE standard).

    Raises:
        ValueError: If mean L* < [_MIN_LIGHTNESS].
    """
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)
    mean_l = float(np.mean(lab[:, :, 0])) / 2.55
    logger.debug("[Colorimetry] Mean L*=%.1f", mean_l)
    if mean_l < _MIN_LIGHTNESS:
        raise ValueError(
            f"Image too dark (mean L*={mean_l:.1f} < {_MIN_LIGHTNESS}). "
            "Move to better lighting and retry."
        )


# ── Step 2 — White balance (LAB Grey-World) ───────────────────────────────────

def _white_balance_lab(image: np.ndarray) -> np.ndarray:
    """
    Applies Grey-World white balance in CIE LAB colour space.

    LAB separates luminance (L*) from chromaticity (a*, b*), giving more
    accurate colour neutralisation under mixed ambient lighting.

    The a* and b* channels are shifted so their average equals the grey-point
    (128 in OpenCV's 0-255 LAB encoding), weighted by luminance.

    A mild bilateral filter removes noise while preserving sticker edges.
    """
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB).astype(np.float64)

    avg_a = np.average(lab[:, :, 1])
    avg_b = np.average(lab[:, :, 2])

    lab[:, :, 1] -= (avg_a - 128) * (lab[:, :, 0] / 255.0) * 1.1
    lab[:, :, 2] -= (avg_b - 128) * (lab[:, :, 0] / 255.0) * 1.1

    lab = np.clip(lab, 0, 255).astype(np.uint8)
    balanced = cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)
    return cv2.bilateralFilter(balanced, d=9, sigmaColor=75, sigmaSpace=75)


# ── Step 3 — Sticker isolation ────────────────────────────────────────────────

def _build_sticker_mask(image: np.ndarray) -> np.ndarray:
    """
    Builds a binary mask for potential sticker regions using HSV.

    Three bands are OR-combined to cover all UV exposure states:

    Band 1 — Vivid (S ≥ 60, V ≥ 50):
        Medium-to-heavily exposed sticker (orange, dark orange, brown).
        Also catches any clearly-saturated coloured object.

    Band 2 — Warm pale (H = 0-40 or 155-179, S = 15-59, V ≥ 90):
        Lightly-exposed sticker with pale orange / peach tint (≈10-30% UV).
        Hue restriction excludes blue/green backgrounds.
        S floor lowered from 30 → 15 to catch less-exposed states.

    Band 3 — Near-fresh (H = 0-50, S = 8-14, V ≥ 160):
        Fresh or minimally exposed sticker with very subtle cream / yellow tint.
        Very strict brightness floor (V ≥ 160) avoids dark-neutral confounders.
        Geometric shape scoring is the primary false-positive guard at this level.

    False-positive protection at the mask level relies on hue restriction — only
    warm (orange/red/yellow) hues are captured.  Final rejection of non-sticker
    shapes (skin, wall edges, fabric) is handled by the contour scoring step.

    Morphological closing fills holes inside the sticker body.
    Opening removes isolated noise specks.
    """
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

    # Band 1: clearly saturated — medium/heavy UV exposure.
    vivid_mask = cv2.inRange(hsv, (0, 60, 50), (179, 255, 255))

    # Band 2: warm pale — light UV exposure (≈10-30%), pale orange/peach tint.
    warm_low = cv2.inRange(hsv, (0, 15, 90), (40, 59, 255))
    warm_high = cv2.inRange(hsv, (155, 15, 90), (179, 59, 255))
    warm_pale_mask = cv2.bitwise_or(warm_low, warm_high)

    # Band 3: near-fresh — very subtle cream/yellow tint (≈0-10% UV).
    fresh_mask = cv2.inRange(hsv, (5, 8, 160), (50, 14, 255))

    combined = cv2.bitwise_or(vivid_mask, warm_pale_mask)
    combined = cv2.bitwise_or(combined, fresh_mask)

    close_k = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (11, 11))
    combined = cv2.morphologyEx(combined, cv2.MORPH_CLOSE, close_k)

    open_k = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    combined = cv2.morphologyEx(combined, cv2.MORPH_OPEN, open_k)

    return combined


def _score_contour(contour: np.ndarray, image_area: int) -> float:
    """
    Computes a 0.0–1.0 sticker likelihood score for a contour.

    Hard constraints (any failure → 0.0):
    - Absolute area ≥ [_MIN_STICKER_AREA_PX2]
    - Relative area within [_MIN_STICKER_AREA_FRACTION, _MAX_STICKER_AREA_FRACTION]
    - Aspect ratio (w/h) within [_MIN_ASPECT_RATIO, _MAX_ASPECT_RATIO]
    - Compactness ≥ [_MIN_COMPACTNESS]
    - Fill ratio (contour_area / bbox_area) ≥ [_MIN_FILL_RATIO]

    Soft scoring (weighted sum → final score):
    - area_score:    peaks at 3–15 % of image area
    - aspect_score:  peaks at 1.0 (perfect square/circle)
    - compact_score: peaks at 1.0 (circle)
    - fill_score:    peaks at 1.0 (full bbox coverage)
    """
    area = cv2.contourArea(contour)
    if area < _MIN_STICKER_AREA_PX2:
        return 0.0

    rel_area = area / image_area
    if rel_area < _MIN_STICKER_AREA_FRACTION or rel_area > _MAX_STICKER_AREA_FRACTION:
        return 0.0

    x, y, w, h = cv2.boundingRect(contour)
    if h == 0:
        return 0.0

    aspect = w / h
    if aspect < _MIN_ASPECT_RATIO or aspect > _MAX_ASPECT_RATIO:
        return 0.0

    perimeter = cv2.arcLength(contour, closed=True)
    if perimeter < 1:
        return 0.0

    compactness = (4.0 * math.pi * area) / (perimeter ** 2)
    if compactness < _MIN_COMPACTNESS:
        return 0.0

    bbox_area = w * h
    fill_ratio = area / bbox_area if bbox_area > 0 else 0.0
    if fill_ratio < _MIN_FILL_RATIO:
        return 0.0

    # ── Soft scores ───────────────────────────────────────────────────────────
    area_score = max(0.0, 1.0 - abs(math.log10(max(rel_area, 1e-6)) + 1.3) / 1.8)
    area_score = min(1.0, area_score)
    aspect_score = max(0.0, 1.0 - abs(aspect - 1.0) * 1.1)
    compact_score = min(compactness, 1.0)
    fill_score = min(fill_ratio, 1.0)

    score = (
        0.20 * area_score
        + 0.20 * aspect_score
        + 0.40 * compact_score
        + 0.20 * fill_score
    )
    return round(score, 3)


def _find_best_sticker_contour(
    image: np.ndarray,
) -> tuple[np.ndarray | None, float]:
    """
    Finds the contour that best matches the expected sticker shape.

    Returns:
        (best_contour, confidence) — contour is None if nothing qualifies.
    """
    mask = _build_sticker_mask(image)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return None, 0.0

    image_area = image.shape[0] * image.shape[1]
    best_contour = None
    best_score = 0.0

    for cnt in contours:
        score = _score_contour(cnt, image_area)
        if score > best_score:
            best_score = score
            best_contour = cnt

    return best_contour, best_score


def _isolate_sticker_pixels(image: np.ndarray) -> np.ndarray:
    """
    Locates the sticker contour and returns ONLY the pixels inside it.

    Unlike the previous approach that returned the bounding-rectangle ROI,
    this function draws a filled mask from the winning contour and extracts
    the exact sticker pixels.  Background pixels in the corners of the
    bounding box are excluded entirely, preventing them from diluting the
    K-Means colour estimation.

    Returns:
        1-D array of shape (N, 3) — BGR pixel values inside the contour.

    Raises:
        ValueError: Specific error codes used by the endpoint for user feedback.
    """
    best_contour, confidence = _find_best_sticker_contour(image)

    if best_contour is None:
        raise ValueError("sticker_not_detected")

    image_area = image.shape[0] * image.shape[1]
    area = cv2.contourArea(best_contour)

    if area < _MIN_STICKER_AREA_PX2:
        raise ValueError(
            f"sticker_too_small (area={area:.0f} px² < {_MIN_STICKER_AREA_PX2} px²). "
            "Hold the camera closer to the sticker."
        )

    rel_area = area / image_area
    if rel_area > _MAX_STICKER_AREA_FRACTION:
        raise ValueError(
            "sticker_too_close (occupies more than 30% of frame). "
            "Move the camera slightly further from the sticker."
        )

    if confidence < _DETECTION_CONFIDENCE_THRESHOLD:
        raise ValueError(
            f"sticker_low_confidence (score={confidence:.2f}). "
            "Ensure the sticker is centred and well-lit."
        )

    # Draw a filled contour mask and extract interior pixels.
    contour_mask = np.zeros(image.shape[:2], dtype=np.uint8)
    cv2.drawContours(contour_mask, [best_contour], -1, 255, thickness=cv2.FILLED)
    pixels = image[contour_mask > 0]  # shape: (N, 3) BGR

    if len(pixels) < _MIN_CONTOUR_PIXELS:
        raise ValueError(
            f"sticker_too_small (only {len(pixels)} pixels inside contour). "
            "Hold the camera closer to the sticker."
        )

    # Reject plain neutral surfaces that passed the shape test.
    hsv_pixels = cv2.cvtColor(
        pixels.reshape(1, -1, 3), cv2.COLOR_BGR2HSV
    )[0]  # shape: (N, 3) HSV
    mean_saturation = float(np.mean(hsv_pixels[:, 1]))
    if mean_saturation < _MIN_ROI_SATURATION:
        logger.debug(
            "[Colorimetry] ROI rejected: mean saturation=%.1f < %d (neutral surface)",
            mean_saturation,
            _MIN_ROI_SATURATION,
        )
        raise ValueError("sticker_not_detected")

    logger.debug(
        "[Colorimetry] Sticker isolated: %.0f px² (%.1f%% of frame), "
        "confidence=%.2f, mean_sat=%.1f",
        area, rel_area * 100, confidence, mean_saturation,
    )
    return pixels


# ── Step 4 — Dominant colour (K-Means k=4, chroma-weighted selection) ─────────

def _dominant_hex_kmeans(pixels: np.ndarray, k: int = 4) -> str:
    """
    Extracts the photochromic indicator colour from sticker pixels.

    Key improvements over naive "largest cluster" approach:

    1. Works directly on contour-masked pixels (no background leakage).
    2. Uses k=4 clusters for finer colour granularity.
    3. Selects the cluster with the highest chroma×count weight:
       - Pure white/grey background clusters (L* > 90 or chroma < 5) are
         downweighted so the coloured dye cluster wins.
       - Very dark clusters (L* < 10) are excluded as shadow artefacts.
    4. Falls back to the largest cluster if all are achromatic (fresh sticker
       with no UV exposure yet — near-white palette is expected).

    Returns:
        Hex string '#RRGGBB' of the dominant indicator cluster centroid.
    """
    pixel_float = pixels.astype(np.float32)

    # Clamp k so sklearn never receives fewer samples than clusters.
    actual_k = min(k, max(2, len(pixel_float) // 10))

    kmeans = KMeans(n_clusters=actual_k, n_init=10, random_state=42)
    kmeans.fit(pixel_float)
    counts = np.bincount(kmeans.labels_)

    # Evaluate each cluster in LAB space.
    best_score = -1.0
    best_idx = int(np.argmax(counts))  # fallback: largest

    for i, center in enumerate(kmeans.cluster_centers_):
        bgr_px = np.uint8([[[int(center[0]), int(center[1]), int(center[2])]]])
        lab = cv2.cvtColor(bgr_px, cv2.COLOR_BGR2LAB)[0][0]

        l_star = float(lab[0]) / 2.55          # 0-100 perceptual scale
        a_star = float(lab[1]) - 128.0
        b_star = float(lab[2]) - 128.0
        chroma = math.sqrt(a_star ** 2 + b_star ** 2)

        # Exclude clusters that are clearly background artefacts.
        if l_star > 92 or l_star < 8:
            continue

        # Score = pixel count × chroma boost.
        # This selects the most coloured region while still preferring
        # larger clusters when chroma values are comparable.
        cluster_score = counts[i] * (1.0 + chroma / 25.0)
        if cluster_score > best_score:
            best_score = cluster_score
            best_idx = i

    dominant_bgr = kmeans.cluster_centers_[best_idx].astype(int)
    b, g, r = int(dominant_bgr[0]), int(dominant_bgr[1]), int(dominant_bgr[2])
    return f"#{r:02X}{g:02X}{b:02X}"


# ── Step 5 — UV% mapping via LAB L* interpolation ────────────────────────────

def _hex_to_uv_percent(hex_color: str) -> float:
    """
    Converts a '#RRGGBB' hex colour to a UV MED percentage via L* interpolation.

    Process:
    1. Parse hex → RGB → OpenCV BGR pixel.
    2. Convert BGR pixel to LAB using OpenCV.
    3. Normalise L* from OpenCV's 0-255 range to CIE 0-100 range (÷ 2.55).
    4. Interpolate L* against the calibration curve (_UV_CURVE).
    5. Clamp result to [0, 100].

    The LAB L* channel is perceptually uniform — small ΔL* corresponds to
    visually meaningful UV exposure changes on the photochromic dye.
    """
    h = hex_color.lstrip("#")
    if len(h) != 6:
        raise ValueError(f"Malformed hex colour: {hex_color}")

    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    bgr_pixel = np.uint8([[[b, g, r]]])
    lab_pixel = cv2.cvtColor(bgr_pixel, cv2.COLOR_BGR2LAB)[0][0]

    l_star = float(lab_pixel[0]) / 2.55
    uv_pct = float(np.clip(_UV_CURVE(l_star), 0.0, 100.0))

    logger.debug("[Colorimetry] L*=%.1f → UV%%=%.1f", l_star, uv_pct)
    return round(uv_pct, 1)
