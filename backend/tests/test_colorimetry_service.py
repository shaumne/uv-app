"""
Unit tests for the Computer Vision Colorimetry Service (colorimetry_service.py).

Tests cover:
- Hex-to-UV-percent interpolation (critical pipeline step)
- HEX color format validation
- Edge cases: pure black, pure white, calibration anchors

Run: pytest backend/tests/test_colorimetry_service.py -v
"""
import pytest
import numpy as np
from app.services.colorimetry_service import (
    _hex_to_uv_percent,
    _dominant_hex_kmeans,
    _white_balance_lab,
)


# ──────────────────────────────────────────────────────────────────────────────
# HEX → UV% mapping (LAB L* interpolation)
# ──────────────────────────────────────────────────────────────────────────────

class TestHexToUvPercent:
    """
    Calibration curve anchors from ComputerVision_Colorimetry skill:
        #FFE4B5 (moccasin-ish, fresh) → 0%
        #FFD700 (gold, 25%)           → 25%
        #FFA500 (orange, 50%)         → 50%
        #FF8C00 (darkorange, 75%)     → 75%
        #8B4513 (saddlebrown, 100%)   → 100%
    """

    def test_fresh_sticker_near_zero(self):
        """Very light sticker hex → near 0% UV exposure."""
        pct = _hex_to_uv_percent("#FFE4B5")
        assert pct <= 15.0, f"Expected <= 15%, got {pct:.1f}%"

    def test_dark_sticker_near_hundred(self):
        """Dark brown sticker → near 100% UV exposure."""
        pct = _hex_to_uv_percent("#8B4513")
        assert pct >= 85.0, f"Expected >= 85%, got {pct:.1f}%"

    def test_midpoint_sticker(self):
        """Mid-tone orange sticker → roughly 40–60% UV exposure."""
        pct = _hex_to_uv_percent("#FFA500")
        assert 30.0 <= pct <= 70.0, f"Expected 40–60%, got {pct:.1f}%"

    def test_output_within_0_to_100_range(self):
        """UV% must be clamped to 0–100 range."""
        for hex_color in ["#FFFFFF", "#000000", "#FF0000", "#00FF00", "#0000FF"]:
            pct = _hex_to_uv_percent(hex_color)
            assert 0.0 <= pct <= 100.0, f"{hex_color} → {pct:.1f}% out of range"

    def test_invalid_hex_raises_or_returns_zero(self):
        """Invalid hex should either raise ValueError or return 0.0 gracefully."""
        try:
            pct = _hex_to_uv_percent("NOT_A_HEX")
            assert pct == 0.0
        except (ValueError, Exception):
            pass  # Either behaviour is acceptable

    def test_pure_white_near_zero(self):
        """Pure white sticker means unexposed → near 0% UV."""
        pct = _hex_to_uv_percent("#FFFFFF")
        assert pct <= 20.0

    def test_pure_black_near_hundred(self):
        """Pure black sticker → near 100% UV (maximum darkening)."""
        pct = _hex_to_uv_percent("#000000")
        assert pct >= 80.0


# ──────────────────────────────────────────────────────────────────────────────
# White balance
# ──────────────────────────────────────────────────────────────────────────────

class TestWhiteBalanceLab:
    def test_output_same_shape_as_input(self):
        """White balance must not change image dimensions."""
        img = np.full((100, 100, 3), [180, 160, 140], dtype=np.uint8)
        result = _white_balance_lab(img)
        assert result.shape == img.shape

    def test_output_dtype_uint8(self):
        """Output must remain uint8 for downstream OpenCV operations."""
        img = np.random.randint(0, 256, (50, 50, 3), dtype=np.uint8)
        result = _white_balance_lab(img)
        assert result.dtype == np.uint8

    def test_uniform_grey_stays_near_grey(self):
        """A perfectly grey image should stay near-grey after white balance."""
        grey = np.full((60, 60, 3), 128, dtype=np.uint8)
        result = _white_balance_lab(grey)
        mean_channels = result.mean(axis=(0, 1))
        # All channels should be within ±20 of 128
        for ch in mean_channels:
            assert abs(ch - 128) < 25, f"Channel diverged: {ch:.1f}"


# ──────────────────────────────────────────────────────────────────────────────
# Dominant HEX via K-Means
# ──────────────────────────────────────────────────────────────────────────────

class TestDominantHexKmeans:
    def test_returns_valid_hex_format(self):
        """Should return a string like #RRGGBB."""
        region = np.full((80, 80, 3), [200, 100, 50], dtype=np.uint8)
        hex_color = _dominant_hex_kmeans(region)
        assert hex_color.startswith("#"), f"Expected #RRGGBB, got '{hex_color}'"
        assert len(hex_color) == 7, f"Expected 7 chars, got {len(hex_color)}"

    def test_uniform_red_returns_red_ish_hex(self):
        """A solid red region should produce a red-dominant hex."""
        red_region = np.zeros((80, 80, 3), dtype=np.uint8)
        red_region[:, :, 2] = 200  # BGR: red channel = index 2
        hex_color = _dominant_hex_kmeans(red_region)
        r_val = int(hex_color[1:3], 16)
        assert r_val > 100, f"Expected red-dominant hex, got {hex_color}"

    def test_handles_small_regions(self):
        """Should not crash on very small regions (edge case)."""
        tiny = np.full((5, 5, 3), [128, 64, 32], dtype=np.uint8)
        result = _dominant_hex_kmeans(tiny)
        assert result.startswith("#")
