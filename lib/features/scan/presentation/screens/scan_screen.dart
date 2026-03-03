import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../onboarding/presentation/providers/skin_profile_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/pulse_overlay_frame.dart';

/// Full-screen immersive camera scan screen.
///
/// Design follows Premium_Cosmeceutical_UI_Designer skill:
/// - Full-bleed camera preview (no bezels)
/// - Edge vignette overlay
/// - PulseOverlayFrame centred
/// - Bottom sheet: instruction + torch toggle + capture button
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
    if (mounted) {
      setState(() => _cameraController = ctrl);
    }
  }

  @override
  void dispose() {
    // CameraController disposed inside ScanNotifier.dispose()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanNotifierProvider);
    final notifier = ref.read(scanNotifierProvider.notifier);

    // Navigate to result on success
    ref.listen<ScanState>(scanNotifierProvider, (_, next) {
      if (next.status == ScanStatus.success && next.result != null) {
        context.go(RouteNames.result, extra: next.result);
      }
      if (next.status == ScanStatus.error && next.failure != null) {
        _showFailureSnackbar(next.failure!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera preview ──────────────────────────────────────────────
          _buildCameraPreview(),

          // ── Vignette overlay ────────────────────────────────────────────
          const _VignetteOverlay(),

          // ── Pulse frame — centre of screen ──────────────────────────────
          if (!scanState.isLoading) const Center(child: PulseOverlayFrame()),

          // ── Analysing spinner ───────────────────────────────────────────
          if (scanState.isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    scanState.status == ScanStatus.capturing
                        ? 'Capturing…'
                        : 'Analysing sticker…',
                    style: AppTypography.bodyMedium
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),

          // ── Back button ─────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => context.go(RouteNames.home),
            ),
          ),

          // ── Bottom controls ─────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              isTorchOn: scanState.isTorchOn,
              isCapturing: scanState.isLoading,
              onTorchToggle: notifier.toggleTorch,
              onCapture: () => _capture(notifier),
            ),
          ),
        ],
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
    final profile = profileAsync.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    await notifier.captureAndAnalyse(
      fitzpatrickType: profile?.fitzpatrickType ?? 2,
      spf: profile?.spf ?? 30,
    );
  }

  void _showFailureSnackbar(Failure failure) {
    if (!mounted) return;
    final msg = switch (failure) {
      NetworkFailure() => 'No internet connection.',
      CameraFailure() => failure.message,
      ImageProcessingFailure() => failure.message,
      ServerFailure() => 'Server error. Please try again.',
      _ => 'Something went wrong.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.uvDangerCoral,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _capture(ref.read(scanNotifierProvider.notifier)),
        ),
      ),
    );
  }
}

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

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.isTorchOn,
    required this.isCapturing,
    required this.onTorchToggle,
    required this.onCapture,
  });

  final bool isTorchOn;
  final bool isCapturing;
  final VoidCallback onTorchToggle;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Align the sticker inside the frame',
            style:
                AppTypography.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Torch toggle
              IconButton(
                icon: Icon(
                  isTorchOn ? Icons.flashlight_on : Icons.flashlight_off,
                  color: isTorchOn ? AppColors.uvWarnAmber : Colors.white54,
                  size: 28,
                ),
                onPressed: onTorchToggle,
              ),

              // Capture button
              GestureDetector(
                onTap: isCapturing ? null : onCapture,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCapturing
                        ? Colors.white38
                        : Colors.white,
                    border: Border.all(
                      color: Colors.white38,
                      width: 4,
                    ),
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

              // Placeholder — symmetric spacing
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}
