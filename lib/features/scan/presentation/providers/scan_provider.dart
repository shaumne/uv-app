import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../result/domain/entities/uv_analysis_result.dart';
import '../../data/datasources/scan_remote_datasource.dart';
import '../../data/repositories/scan_repository_impl.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/usecases/analyze_sticker.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final scanRemoteDatasourceProvider = Provider<ScanRemoteDatasource>(
  (ref) => ScanRemoteDatasourceImpl(ref.watch(dioProvider)),
);

final analyzeStickerUseCaseProvider = Provider<_ScanDependencies>((ref) {
  return _ScanDependencies(
    remoteDatasource: ref.watch(scanRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Bundles Scan infrastructure dependencies for injection into [ScanNotifier].
class _ScanDependencies {
  const _ScanDependencies({
    required this.remoteDatasource,
    required this.networkInfo,
  });
  final ScanRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
}

// ── State ─────────────────────────────────────────────────────────────────────

enum ScanStatus { idle, capturing, analysing, success, error }

class ScanState {
  const ScanState({
    this.status = ScanStatus.idle,
    this.result,
    this.failure,
    this.isTorchOn = false,
  });

  final ScanStatus status;
  final UvAnalysisResult? result;
  final Failure? failure;
  final bool isTorchOn;

  bool get isLoading =>
      status == ScanStatus.capturing || status == ScanStatus.analysing;

  ScanState copyWith({
    ScanStatus? status,
    UvAnalysisResult? result,
    Failure? failure,
    bool? isTorchOn,
  }) =>
      ScanState(
        status: status ?? this.status,
        result: result ?? this.result,
        failure: failure,
        isTorchOn: isTorchOn ?? this.isTorchOn,
      );
}

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier({
    required _ScanDependencies deps,
    required this.currentDoseJm2,
    required this.currentUvIndex,
  })  : _deps = deps,
        super(const ScanState());

  final _ScanDependencies _deps;
  final double currentDoseJm2;
  final double currentUvIndex;

  CameraController? _cameraController;

  /// Initialises the rear camera. Returns the controller for the UI preview.
  Future<CameraController?> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        state = state.copyWith(
          status: ScanStatus.error,
          failure: const CameraFailure('No cameras available on this device.'),
        );
        return null;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        back,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      return _cameraController;
    } on CameraException catch (e) {
      appLogger.e('[ScanNotifier] Camera init error', error: e);
      state = state.copyWith(
        status: ScanStatus.error,
        failure: CameraFailure(e.description ?? 'Camera initialisation failed.'),
      );
      return null;
    }
  }

  /// Toggles the camera flashlight (torch mode).
  Future<void> toggleTorch() async {
    final ctrl = _cameraController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    final next = !state.isTorchOn;
    await ctrl.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    state = state.copyWith(isTorchOn: next);
  }

  /// Captures a photo and sends it to the FastAPI analysis endpoint.
  ///
  /// Returns [UvAnalysisResult] on success, null on failure.
  /// Failure is stored in [ScanState.failure] for UI display.
  Future<UvAnalysisResult?> captureAndAnalyse({
    required int fitzpatrickType,
    required int spf,
    double ambientLux = 1000.0,
    double hoursSinceApplication = 0.0,
  }) async {
    final ctrl = _cameraController;
    if (ctrl == null || !ctrl.value.isInitialized) {
      state = state.copyWith(
        status: ScanStatus.error,
        failure: const CameraFailure('Camera not ready. Please wait.'),
      );
      return null;
    }

    state = state.copyWith(status: ScanStatus.capturing, failure: null);

    XFile? photo;
    try {
      photo = await ctrl.takePicture();
    } on CameraException catch (e) {
      appLogger.e('[ScanNotifier] Capture failed', error: e);
      state = state.copyWith(
        status: ScanStatus.error,
        failure: CameraFailure(e.description ?? 'Photo capture failed.'),
      );
      return null;
    }

    state = state.copyWith(status: ScanStatus.analysing);

    final request = ScanRequest(
      imagePath: photo.path,
      ambientLux: ambientLux,
      fitzpatrickType: fitzpatrickType,
      spf: spf,
    );

    final repository = ScanRepositoryImpl(
      remoteDatasource: _deps.remoteDatasource,
      networkInfo: _deps.networkInfo,
      cumulativeDoseJm2: currentDoseJm2,
      uvIndex: currentUvIndex,
      hoursSinceApplication: hoursSinceApplication,
    );

    final either = await AnalyzeSticker(repository)(request);

    // Clean up temp file regardless of result
    try {
      await File(photo.path).delete();
    } catch (_) {}

    return either.fold(
      (failure) {
        appLogger.w('[ScanNotifier] Failure: ${failure.message}');
        state = state.copyWith(status: ScanStatus.error, failure: failure);
        return null;
      },
      (result) {
        state = state.copyWith(status: ScanStatus.success, result: result);
        return result;
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

final scanNotifierProvider =
    StateNotifierProvider.autoDispose<ScanNotifier, ScanState>((ref) {
  final homeState = ref.watch(homeNotifierProvider);
  final deps = ref.watch(analyzeStickerUseCaseProvider);

  // Approximate current dose from home summary fraction × Type II MED baseline
  final doseJm2 = (homeState.doseSummary?.medUsedFraction ?? 0.0) * 250.0;
  final uvIdx = homeState.uvIndex?.value ?? 5.0;

  return ScanNotifier(
    deps: deps,
    currentDoseJm2: doseJm2,
    currentUvIndex: uvIdx,
  );
});
