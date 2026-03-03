"""
Application configuration loaded from environment variables.

Uses pydantic-settings so values can be overridden via .env file
or Docker / CI environment variables without code changes.
"""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_name: str = "UV Dosimeter API"
    app_version: str = "1.0.0"
    debug: bool = False

    # Image processing limits
    max_image_size_bytes: int = 10 * 1024 * 1024  # 10 MB
    min_image_dimension_px: int = 200              # width and height

    # CORS (set to specific origin in production)
    allowed_origins: list[str] = ["*"]


settings = Settings()
