# Assets — Images

Place app images here.

## Splash screen

To use a custom splash logo with `flutter_native_splash`:

1. Add `splash_logo.png` (recommended: 288×288 px or larger, transparent or white on transparent for light theme).
2. In `pubspec.yaml`, uncomment under `flutter_native_splash`:
   - `image: assets/images/splash_logo.png`
3. Run: `dart run flutter_native_splash:create`

If no image is set, the splash uses the configured background colour only (`#F9F7F5` / `#1A1A2E` for dark).
