"""
FastAPI application factory.

Registers:
- CORS middleware (origins controlled via [Settings.allowed_origins])
- /api/v1 router with the /analyze endpoint
- Global exception handlers for unhandled errors
"""
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .api.v1.endpoints.analyze import router as analyze_router
from .core.config import settings
from .core.logging import configure_logging, logger


def create_app() -> FastAPI:
    configure_logging(debug=settings.debug)

    app = FastAPI(
        title=settings.app_name,
        version=settings.app_version,
        docs_url="/docs" if settings.debug else None,
        redoc_url="/redoc" if settings.debug else None,
    )

    # ── CORS ─────────────────────────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.allowed_origins,
        allow_methods=["POST", "GET"],
        allow_headers=["*"],
    )

    # ── Routers ──────────────────────────────────────────────────────────────
    app.include_router(analyze_router, prefix="/api/v1")

    # ── Global exception handler ──────────────────────────────────────────────
    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        logger.exception("Unhandled exception at %s", request.url)
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": "An unexpected server error occurred.", "code": "INTERNAL_ERROR"},
        )

    @app.get("/health", tags=["Monitoring"])
    async def health_check() -> dict[str, str]:
        return {"status": "ok", "version": settings.app_version}

    return app


app = create_app()
