import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/error/exceptions.dart'
    hide CameraException; // camera package defines its own CameraException
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/ambient_light_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../result/domain/entities/uv_analysis_result.dart';
import '../../data/datasources/scan_remote_datasource.dart';
import '../../data/utils/guide_roi_crop.dart';
import '../../data/repositories/scan_repository_impl.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/usecases/analyze_sticker.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final scanRemoteDatasourceProvider = Provider<ScanRemoteDatasource>(
  (ref) => ScanRemoteDatasourceImpl(ref.watch(dioProvider)),
);

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepositoryImpl(
    remoteDatasource: ref.watch(scanRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final analyzeStickerUseCaseProvider = Provider<_ScanDependencies>((ref) {
  return _ScanDependencies(
    repository: ref.watch(scanRepositoryProvider),
    remoteDatasource: ref.watch(scanRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
    ambientLightService: ref.watch(ambientLightServiceProvider),
  );
});

/// Bundles Scan infrastructure dependencies for injection into [ScanNotifier].
class _ScanDependencies {
  const _ScanDependencies({
    required this.repository,
    required this.remoteDatasource,
    required this.networkInfo,
    required this.ambientLightService,
  });
  final ScanRepository repository;
  final ScanRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final AmbientLightService ambientLightService;
}

// ── State ─────────────────────────────────────────────────────────────────────

/// Scan pipeline stages — executed sequentially on each capture attempt.
///
/// idle      → camera ready, waiting for user tap
/// capturing → shutter fired, photo being taken
/// detecting → /detect running on captured photo
/// analysing → /analyze running (detection passed)
/// success   → result ready, navigation triggered
/// error     → pipeline failed at any stage, snackbar shown
enum ScanStatus { idle, capturing, detecting, analysing, success, error }

class ScanState {
  const ScanState({
    this.status = ScanStatus.idle,
    this.result,
    this.failure,
    this.isTorchOn = false,
    this.isCameraReady = false,
  });

  final ScanStatus status;
  final UvAnalysisResult? result;
  final Failure? failure;
  final bool isTorchOn;

  /// True once [CameraController.initialize()] has completed successfully.
  final bool isCameraReady;

  /// Capture is allowed when the camera is ready and the pipeline is not busy.
  bool get canCapture => isCameraReady && !isLoading;

  /// True during any stage that blocks the capture button and shows a spinner.
  bool get isLoading =>
      status == ScanStatus.capturing ||
      status == ScanStatus.detecting ||
      status == ScanStatus.analysing;

  ScanState copyWith({
    ScanStatus? status,
    UvAnalysisResult? result,
    Failure? failure,
    bool? isTorchOn,
    bool? isCameraReady,
  }) =>
      ScanState(
        status: status ?? this.status,
        result: result ?? this.result,
        failure: failure,
        isTorchOn: isTorchOn ?? this.isTorchOn,
        isCameraReady: isCameraReady ?? this.isCameraReady,
      );
}

/// Handles the full capture → detect → analyse pipeline.
///
/// Pipeline (per [captureAndAnalyse] call):
///   1. [ScanStatus.capturing]  — [CameraController.takePicture]
///   2. [ScanStatus.detecting]  — POST /detect with the captured image
///   3. if detected == false    — error state (sticker not found), file deleted
///   4. [ScanStatus.analysing]  — POST /analyze with the same image
///   5. [ScanStatus.success]    — result stored, UI navigates away
///
/// No background polling loop is used. The camera preview runs passively
/// until the user taps the shutter button, conserving battery and avoiding
/// concurrent-capture race conditions.
class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier({required _ScanDependencies deps}) : _deps = deps, super(const ScanState());

  final _ScanDependencies _deps;

  CameraController? _cameraController;

  /// Initialises the rear camera and returns the controller for the UI preview.
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
      state = state.copyWith(isCameraReady: true, status: ScanStatus.idle);
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

  /// Resets to idle after an error so the user can tap the shutter again.
  void resetAfterError() {
    if (state.status == ScanStatus.error) {
      state = state.copyWith(status: ScanStatus.idle, failure: null);
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

  /// Releases the camera controller (dispose + null). Call before leaving the
  /// scan screen (e.g. back gesture) to avoid crash when the route is popped.
  void releaseCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    state = state.copyWith(isCameraReady: false);
  }

  /// Full scan pipeline: capture → crop to guide ROI → detect → analyse.
  ///
  /// Steps:
  ///   1. Takes a photo and reads ambient lux in parallel (same moment).
  ///   2. Crops to the guide circle region so API receives only that area.
  ///   3. Sends cropped image to /detect, then /analyze. Only purple/sticker shape in ROI is accepted.
  ///
  /// Original and cropped temp files are deleted after use.
  ///
  /// [cumulativeDoseJm2] and [uvIndex] are passed at call time (from home state)
  /// so the notifier stays stateless and avoids unnecessary rebuilds.
  Future<UvAnalysisResult?> captureAndAnalyse({
    required int fitzpatrickType,
    required int spf,
    required double cumulativeDoseJm2,
    required double uvIndex,
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

    // ── Stage 1: Capture & read lux simultaneously ───────────────────────────
    // Future.wait ensures we get the light reading from the exact moment of shutter.
    state = state.copyWith(status: ScanStatus.capturing, failure: null);

    XFile? photo;
    double currentLux = AmbientLightService.fallbackLux;
    try {
      final results = await Future.wait([
        ctrl.takePicture(),
        _deps.ambientLightService.getCurrentLux(),
      ]);
      photo = results[0] as XFile;
      currentLux = results[1] as double;
    } on CameraException catch (e) {
      appLogger.e('[ScanNotifier] Capture failed', error: e);
      state = state.copyWith(
        status: ScanStatus.error,
        failure: CameraFailure(e.description ?? 'Photo capture failed.'),
      );
      return null;
    }

    // ── Crop to guide ROI (kılavuz daire = sadece o alan API'ye gider) ───────
    String imagePathForApi = photo.path;
    try {
      imagePathForApi = await cropImageToGuideRoi(photo.path);
    } catch (e, st) {
      appLogger.w('[ScanNotifier] Guide ROI crop failed', error: e, stackTrace: st);
      _deleteFile(photo.path);
      state = state.copyWith(
        status: ScanStatus.error,
        failure: ImageProcessingFailure('Failed to prepare image. Please try again.'),
      );
      return null;
    }

    // ── Stage 2: Detect ─────────────────────────────────────────────────────
    state = state.copyWith(status: ScanStatus.detecting);

    StickerDetectionResult? detection;
    try {
      detection = await _deps.remoteDatasource.detectSticker(
        imagePath: imagePathForApi,
        ambientLux: currentLux,
      );
    } on NetworkException catch (e) {
      appLogger.e('[ScanNotifier] /detect network error', error: e);
      _deleteFile(photo.path);
      _deleteFile(imagePathForApi);
      state = state.copyWith(
        status: ScanStatus.error,
        failure: NetworkFailure(e.message),
      );
      return null;
    } on ImageProcessingException catch (e) {
      appLogger.w('[ScanNotifier] /detect image error: ${e.message}');
      _deleteFile(photo.path);
      _deleteFile(imagePathForApi);
      state = state.copyWith(
        status: ScanStatus.error,
        failure: ImageProcessingFailure(e.message),
      );
      return null;
    } catch (e, st) {
      appLogger.e('[ScanNotifier] /detect unexpected error', error: e, stackTrace: st);
      _deleteFile(photo.path);
      _deleteFile(imagePathForApi);
      state = state.copyWith(
        status: ScanStatus.error,
        failure: const ImageProcessingFailure('Detection request failed. Please try again.'),
      );
      return null;
    }

    if (!detection.detected) {
      final reason = detection.reason ?? 'sticker_not_detected';
      appLogger.i('[ScanNotifier] Detection blocked. reason=$reason confidence=${detection.confidence}');
      _deleteFile(photo.path);
      _deleteFile(imagePathForApi);
      state = state.copyWith(
        status: ScanStatus.error,
        failure: ImageProcessingFailure(reason),
      );
      return null;
    }

    appLogger.d('[ScanNotifier] Sticker detected (confidence=${detection.confidence.toStringAsFixed(2)})');

    // ── Stage 3: Analyse ────────────────────────────────────────────────────
    state = state.copyWith(status: ScanStatus.analysing);

    final request = ScanRequest(
      imagePath: imagePathForApi,
      ambientLux: currentLux,
      fitzpatrickType: fitzpatrickType,
      spf: spf,
      cumulativeDoseJm2: cumulativeDoseJm2,
      uvIndex: uvIndex,
      hoursSinceApplication: hoursSinceApplication,
    );

    final either = await AnalyzeSticker(_deps.repository)(request);

    _deleteFile(photo.path);
    _deleteFile(imagePathForApi);

    return either.fold(
      (failure) {
        appLogger.w('[ScanNotifier] /analyze failure: ${failure.message}');
        state = state.copyWith(status: ScanStatus.error, failure: failure);
        return null;
      },
      (result) {
        state = state.copyWith(status: ScanStatus.success, result: result);
        return result;
      },
    );
  }

  /// Deletes a temp image file silently — errors are swallowed.
  void _deleteFile(String path) {
    try { File(path).deleteSync(); } catch (_) {}
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

final scanNotifierProvider =
    StateNotifierProvider.autoDispose<ScanNotifier, ScanState>((ref) {
  final deps = ref.watch(analyzeStickerUseCaseProvider);
  return ScanNotifier(deps: deps);
});
