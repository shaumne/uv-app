# UV Dosimeter

Dynamic UV Dosimeter Patch and AI Dermatologist — a Flutter app that works with a photochromic sticker to measure personal UV exposure and recommend safe sun time based on Fitzpatrick skin type and SPF.

## Features

- **Onboarding**: Fitzpatrick skin type (I–VI) and sunscreen SPF selection
- **Home**: Location-based UV index, daily dose gauge, remaining safe time, scan CTA
- **Scan**: Camera capture with sticker alignment guide; detect → analyze via backend API
- **Result**: MED used, risk level, recommended action (reapply sunscreen, seek shade, etc.)
- **History**: 7-day dose summary (premium-gated in code; toggle off by default)
- **Settings**: Language (en / ja / tr), skin profile, SPF application time, reset onboarding
- **Localization**: Full English, Japanese, and Turkish (ARB-based)

## Tech stack

- **Flutter** (Dart), **Riverpod**, **GoRouter**
- **Backend**: Python **FastAPI** (OpenCV colorimetry, MED calculator)
- **Camera**, **permission_handler**, **geolocator**, **ambient_light** (optional lux for scan)

## Prerequisites

- Flutter SDK (see `environment.sdk` in `pubspec.yaml`)
- Python 3.10+ for the backend (see `backend/`)

## Quick start

### 1. Clone and install

```bash
cd uv_dosimeter
flutter pub get
```

### 2. Run the app

**Default backend** (no env needed): app uses the default API base URL (e.g. AWS EC2).

```bash
flutter run
```

**Custom backend** (e.g. local or staging): pass the API base URL at build/run time:

```bash
# Android emulator (host machine = 10.0.2.2)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1

# Physical device on same LAN
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000/api/v1

# Production
flutter run --dart-define=API_BASE_URL=https://api.uvdosimetry.com/api/v1
```

For **release builds**:

```bash
flutter build apk --dart-define=API_BASE_URL=https://api.uvdosimetry.com/api/v1
```

### 3. Run the backend (optional — for local development)

From the project root:

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate   # Windows
# source .venv/bin/activate  # macOS/Linux
pip install -r requirements.txt
uvicorn app.main:create_app --factory --host 0.0.0.0 --port 8000
```

The API serves:

- `POST /api/v1/analyze` — sticker image + params → UV risk and MED
- `POST /api/v1/detect` — sticker presence check
- `GET /health` — health check

See `backend/app/` for structure and `app/core/config.py` for settings.

## Environment variables (Flutter)

| Variable         | Description                    | Default (example)                    |
|------------------|--------------------------------|--------------------------------------|
| `API_BASE_URL`   | Backend API base URL           | `http://16.170.120.34:8000/api/v1`   |

Set via `--dart-define=API_BASE_URL=...` as above.

## Project structure

```
uv_dosimeter/
├── lib/
│   ├── app/           # DI, router
│   ├── core/          # config, error, network, services, theme
│   ├── features/      # home, onboarding, scan, result, history, settings, premium
│   └── l10n/          # ARB (en, ja, tr) and generated localizations
├── backend/           # FastAPI (analyze, detect, colorimetry, MED)
├── assets/images/     # Splash image (see assets/images/README.md)
└── test/
```

## Splash screen

Splash uses `flutter_native_splash` (background color only by default). To add a logo:

1. Add `splash_logo.png` under `assets/images/`.
2. In `pubspec.yaml`, under `flutter_native_splash`, set `image: assets/images/splash_logo.png` and add `assets: [ assets/images/ ]` under `flutter:`.
3. Run: `dart run flutter_native_splash:create`

See `assets/images/README.md` for details.

## Tests

```bash
flutter test
```

## License and support

- **Support**: support@uvdosimetry.com (configurable in app)
- **Docs**: `docs/` (e.g. `GELISTIRME_EKSIKLERI_RAPORU.md`, `SONRAKI_ADIMLAR.md`)
