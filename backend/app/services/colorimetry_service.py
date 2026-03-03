"""
Colorimetry service — OpenCV + scikit-learn UV sticker colour extraction.

Pipeline (matches ComputerVision_Colorimetry skill specification):
1. Decode raw image bytes into a NumPy/BGR array.
2. Apply LAB-space Grey-World white balance correction.
3. Isolate the sticker patch via HSV masking + largest-contour detection.
4. Extract dominant colour with scikit-learn K-Means (k=3, highest-count cluster).
5. Map dominant colour to UV% via LAB L* perceptual interpolation (scipy).
6. Return hex string + uv_percent.

Required packages: opencv-python-headless, scikit-learn, scipy, numpy
"""
import logging

import cv2
import numpy as np
from scipy.interpolate import interp1d
from sklearn.cluster import KMeans

logger = logging.getLogger(__name__)

# ── UV calibration curve ───────────────────────────────────────────────────────
# Maps LAB L* values (0-100 perceptual scale) to cumulative UV MED percentage.
# Derived from photochromic dye lab measurements.
# Update after each physical sticker batch calibration (see reference.md).
_CALIBRATION: list[tuple[float, float]] = [
    (90.0,   0.0),   # fresh / unexposed  — very light
    (75.0,  10.0),
    (60.0,  25.0),
    (45.0,  50.0),
    (30.0,  75.0),
    (15.0, 100.0),   # fully exposed      — very dark
]
_L_VALS, _UV_VALS = zip(*_CALIBRATION)
_UV_CURVE = interp1d(_L_VALS, _UV_VALS, kind="linear", fill_value="extrapolate")

# Minimum sticker contour area in pixels² before fallback is triggered.
_MIN_STICKER_AREA_PX2 = 500

# Minimum mean LAB L* value; below this the image is too dark to analyse.
_MIN_LIGHTNESS = 20.0


def extract_sticker_data(
    image_bytes: bytes,
    ambient_lux: float,
) -> tuple[str, float]:
    """
    Full colorimetry pipeline: image bytes → (hex_color, uv_percent).

    Args:
        image_bytes: Raw JPEG/PNG bytes from the mobile camera.
        ambient_lux: Ambient light sensor reading in lux (used for
                     low-light detection and logging; white balance uses
                     the LAB grey-world algorithm independently).

    Returns:
        Tuple of (hex_color: str, uv_percent: float).
        hex_color is in '#RRGGBB' format.
        uv_percent is in range 0.0 – 100.0+ (values > 100 indicate over-exposure).

    Raises:
        ValueError: If the image cannot be decoded, is too dark,
                    or the sticker region cannot be isolated.
    """
    image = _decode_image(image_bytes)
    _check_lightness(image)
    balanced = _white_balance_lab(image)
    roi = _isolate_sticker(balanced)
    hex_color = _dominant_hex_kmeans(roi)
    uv_percent = _hex_to_uv_percent(hex_color)

    logger.info(
        "[Colorimetry] lux=%.1f hex=%s uv_pct=%.1f",
        ambient_lux,
        hex_color,
        uv_percent,
    )
    return hex_color, uv_percent


# ──────────────────────────────────────────────────────────────────────────────
# Step 1 — Image decode
# ──────────────────────────────────────────────────────────────────────────────

def _decode_image(image_bytes: bytes) -> np.ndarray:
    """Decodes raw bytes into a BGR NumPy array (OpenCV native format)."""
    buffer = np.frombuffer(image_bytes, dtype=np.uint8)
    image = cv2.imdecode(buffer, cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError("Image decoding failed — unsupported format or corrupt data.")
    return image


# ──────────────────────────────────────────────────────────────────────────────
# Step 1b — Darkness check
# ──────────────────────────────────────────────────────────────────────────────

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


# ──────────────────────────────────────────────────────────────────────────────
# Step 2 — White balance (LAB Grey-World)
# ──────────────────────────────────────────────────────────────────────────────

def _white_balance_lab(image: np.ndarray) -> np.ndarray:
    """
    Applies Grey-World white balance in CIE LAB colour space.

    LAB is used instead of RGB because it separates luminance (L*)
    from chromaticity (a*, b*), giving more accurate colour neutralisation
    under mixed ambient lighting.

    The a* and b* channels are shifted so their average equals the
    grey-point (128 in OpenCV's 0-255 LAB encoding), weighted by luminance.

    Afterward a mild bilateral filter removes noise while preserving edges.
    """
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB).astype(np.float64)

    avg_a = np.average(lab[:, :, 1])
    avg_b = np.average(lab[:, :, 2])

    # Shift a* and b* channels toward grey, weighted by L*
    lab[:, :, 1] -= (avg_a - 128) * (lab[:, :, 0] / 255.0) * 1.1
    lab[:, :, 2] -= (avg_b - 128) * (lab[:, :, 0] / 255.0) * 1.1

    lab = np.clip(lab, 0, 255).astype(np.uint8)
    balanced = cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)

    # Mild bilateral filter — smooths noise, preserves sticker edges
    return cv2.bilateralFilter(balanced, d=9, sigmaColor=75, sigmaSpace=75)


# ──────────────────────────────────────────────────────────────────────────────
# Step 3 — Sticker isolation
# ──────────────────────────────────────────────────────────────────────────────

def _isolate_sticker(image: np.ndarray) -> np.ndarray:
    """
    Isolates the sticker patch using HSV saturation masking + contour detection.

    The sticker always has higher saturation than surrounding skin.
    Thresholds: (H: 0-179, S: 60-255, V: 60-255) — any vivid colour.
    The largest contour's bounding rect is used as the ROI.

    Raises:
        ValueError: 'sticker_not_detected' if no contour is found.
        ValueError: 'sticker_too_small' if largest contour area < 500 px².
    """
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(hsv, (0, 60, 60), (179, 255, 255))

    # Morphological cleanup
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        raise ValueError("sticker_not_detected")

    sticker_contour = max(contours, key=cv2.contourArea)
    area = cv2.contourArea(sticker_contour)
    logger.debug("[Colorimetry] Largest contour area: %.0f px²", area)

    if area < _MIN_STICKER_AREA_PX2:
        raise ValueError(
            f"sticker_too_small (area={area:.0f} px² < {_MIN_STICKER_AREA_PX2} px²)"
        )

    x, y, w, h = cv2.boundingRect(sticker_contour)
    roi = image[y : y + h, x : x + w]
    return roi


# ──────────────────────────────────────────────────────────────────────────────
# Step 4 — Dominant colour (K-Means k=3)
# ──────────────────────────────────────────────────────────────────────────────

def _dominant_hex_kmeans(roi: np.ndarray, k: int = 3) -> str:
    """
    Extracts the dominant colour from the ROI using scikit-learn K-Means (k=3).

    k=3 accounts for the sticker's photochromic gradient — the cluster with
    the highest pixel count represents the majority-exposed colour zone.

    Returns:
        Hex string '#RRGGBB' of the dominant cluster centroid.
    """
    pixels = roi.reshape(-1, 3).astype(np.float32)

    kmeans = KMeans(n_clusters=k, n_init=10, random_state=42)
    kmeans.fit(pixels)

    counts = np.bincount(kmeans.labels_)
    dominant_bgr = kmeans.cluster_centers_[np.argmax(counts)].astype(int)
    b, g, r = int(dominant_bgr[0]), int(dominant_bgr[1]), int(dominant_bgr[2])
    return f"#{r:02X}{g:02X}{b:02X}"


# ──────────────────────────────────────────────────────────────────────────────
# Step 5 — UV% mapping via LAB L* interpolation
# ──────────────────────────────────────────────────────────────────────────────

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

    # OpenCV L* range is 0-255; divide by 2.55 for standard 0-100 scale
    l_star = float(lab_pixel[0]) / 2.55

    uv_pct = float(np.clip(_UV_CURVE(l_star), 0.0, 100.0))
    logger.debug("[Colorimetry] L*=%.1f → UV%%=%.1f", l_star, uv_pct)
    return round(uv_pct, 1)
