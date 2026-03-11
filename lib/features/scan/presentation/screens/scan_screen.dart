import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../onboarding/presentation/providers/skin_profile_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/pulse_overlay_frame.dart';

/// Full-screen immersive camera scan screen.
///
/// Pipeline on capture:
///   1. User taps shutter → photo taken
///   2. /detect runs on captured photo
///   3. If sticker not found → snackbar, user retries
///   4. If found → /analyze → result screen
///
/// The camera preview runs passively (no background polling) until the
/// user taps capture. This is resource-efficient and avoids race conditions.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final ctrl = await ref.read(scanNotifierProvider.notifier).initCamera();
    if (mounted) setState(() => _cameraController = ctrl);
  }

  @override
  void dispose() {
    // CameraController is disposed inside ScanNotifier.dispose()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanNotifierProvider);
    final notifier = ref.read(scanNotifierProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    // Navigate to result on success; show snackbar on failure.
    ref.listen<ScanState>(scanNotifierProvider, (_, next) {
      if (next.status == ScanStatus.success && next.result != null) {
        context.go(RouteNames.result, extra: next.result);
      }
      if (next.status == ScanStatus.error && next.failure != null) {
        _showFailureSnackbar(next.failure!, l10n, notifier);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        notifier.releaseCamera();
        if (mounted) context.go(RouteNames.home);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Camera preview ────────────────────────────────────────────────
            _buildCameraPreview(),

            // ── Vignette overlay ──────────────────────────────────────────────
            const _VignetteOverlay(),

            // ── Camera initialising spinner ───────────────────────────────────
            if (!scanState.isCameraReady && !scanState.isLoading)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white54),
                    const SizedBox(height: 12),
                    Text(
                      l10n.scan_cameraStarting,
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),

            // ── Pulse alignment frame — visible when camera is idle ───────────
            if (scanState.isCameraReady && !scanState.isLoading)
              const Center(child: PulseOverlayFrame()),

            // ── Pipeline spinner (capturing / detecting / analysing) ───────────
            if (scanState.isLoading)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _loadingLabel(scanState.status, l10n),
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),

            // ── Back button ───────────────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Semantics(
                button: true,
                label: l10n.scan_back,
                child: IconButton(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.caretLeft,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    notifier.releaseCamera();
                    context.go(RouteNames.home);
                  },
                ),
              ),
            ),

            // ── Bottom controls ───────────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomControls(
                isTorchOn: scanState.isTorchOn,
                isCapturing: scanState.isLoading,
                canCapture: scanState.canCapture,
                guideHint: l10n.scan_guideOverlay_hint,
                onTorchToggle: notifier.toggleTorch,
                onCapture: () => _capture(notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final ctrl = _cameraController;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white38),
      );
    }
    return CameraPreview(ctrl);
  }

  Future<void> _capture(ScanNotifier notifier) async {
    final profileAsync = ref.read(storedSkinProfileProvider);
    final profile = profileAsync.maybeWhen(data: (p) => p, orElse: () => null);
    final homeState = ref.read(homeNotifierProvider);
    const medTable = {1: 200.0, 2: 250.0, 3: 350.0, 4: 500.0, 5: 700.0, 6: 1000.0};
    final fitzpatrick = profile?.fitzpatrickType ?? 2;
    final medBaseline = medTable[fitzpatrick.clamp(1, 6)] ?? 250.0;
    final doseJm2 = (homeState.doseSummary?.medUsedFraction ?? 0.0) * medBaseline;
    final uvIdx = homeState.uvIndex?.value ?? 5.0;

    await notifier.captureAndAnalyse(
      fitzpatrickType: fitzpatrick,
      spf: profile?.spf ?? 30,
      cumulativeDoseJm2: doseJm2,
      uvIndex: uvIdx,
      hoursSinceApplication: profile?.hoursSinceApplication ?? 0.0,
    );
  }

  /// Returns localised spinner label for each pipeline stage.
  String _loadingLabel(ScanStatus status, AppLocalizations l10n) {
    return switch (status) {
      ScanStatus.capturing  => l10n.scan_capturing,
      ScanStatus.detecting  => l10n.scan_sticker_detecting,
      ScanStatus.analysing  => l10n.scan_analysing,
      _                     => l10n.scan_analysing,
    };
  }

  void _showFailureSnackbar(
    Failure failure,
    AppLocalizations l10n,
    ScanNotifier notifier,
  ) {
    if (!mounted) return;

    String localise(String backendMsg) {
      final m = backendMsg.toLowerCase();
      if (m.contains('sticker_not_detected') ||
          m.contains('not detected') ||
          m.contains('no sticker')) {
        return l10n.scan_sticker_notDetected;
      }
      if (m.contains('too_small') || m.contains('too small') || m.contains('closer')) {
        return l10n.scan_sticker_tooSmall;
      }
      if (m.contains('insufficient_lighting') ||
          m.contains('too dark') ||
          m.contains('lighting')) {
        return l10n.scan_sticker_tooDark;
      }
      if (m.contains('low_confidence') ||
          m.contains('low confidence') ||
          m.contains('centre_crop') ||
          m.contains('center_crop')) {
        // Centre-crop fallback — analysis still proceeds; not an error.
        return l10n.scan_sticker_notDetected;
      }
      if (m.contains('processing_error')) {
        return l10n.error_server;
      }
      return backendMsg;
    }

    final msg = switch (failure) {
      NetworkFailure()          => l10n.error_network,
      CameraFailure()           => l10n.error_camera,
      ImageProcessingFailure()  => localise(failure.message),
      ServerFailure()           => failure.message.isNotEmpty
                                      ? localise(failure.message)
                                      : l10n.error_server,
      _                         => l10n.error_unknown,
    };

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.uvDangerCoral,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n.error_retry_button,
          textColor: Colors.white,
          onPressed: () {
            notifier.resetAfterError();
            _capture(notifier);
          },
        ),
        onVisible: () {
          // Auto-reset 4 s after snackbar appears so the capture button
          // becomes tappable again if the user dismisses without pressing Retry.
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) notifier.resetAfterError();
          });
        },
      ),
    );
  }
}

// ── Vignette overlay ──────────────────────────────────────────────────────────

class _VignetteOverlay extends StatelessWidget {
  const _VignetteOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            Colors.transparent,
            AppColors.scanVignette.withValues(alpha: 0.60),
          ],
        ),
      ),
    );
  }
}

// ── Bottom controls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.isTorchOn,
    required this.isCapturing,
    required this.canCapture,
    required this.guideHint,
    required this.onTorchToggle,
    required this.onCapture,
    super.key,
  });

  final bool isTorchOn;
  final bool isCapturing;
  final bool canCapture;
  final String guideHint;
  final VoidCallback onTorchToggle;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 24, 24, 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            guideHint,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Torch toggle
              IconButton(
                icon: PhosphorIcon(
                  isTorchOn
                      ? PhosphorIconsFill.flashlight
                      : PhosphorIconsRegular.flashlight,
                  color: isTorchOn ? AppColors.uvWarnAmber : Colors.white54,
                  size: 28,
                ),
                onPressed: onTorchToggle,
              ),

              // Shutter button
              GestureDetector(
                onTap: (isCapturing || !canCapture) ? null : onCapture,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCapturing
                        ? Colors.white54
                        : canCapture
                            ? Colors.white
                            : Colors.white24,
                    border: Border.all(
                      color: canCapture
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.white24,
                      width: 4,
                    ),
                    boxShadow: canCapture
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.20),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),

              // Symmetric spacing
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}
