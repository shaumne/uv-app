import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/error/exceptions.dart'
    hide CameraException; // camera package defines its own CameraException
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../result/domain/entities/uv_analysis_result.dart';
import '../../data/datasources/scan_remote_datasource.dart';
import '../../data/utils/guide_roi_crop.dart';
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
  ///   1. Takes a photo with the rear camera.
  ///   2. Crops to the guide circle region (centre 45 %) so API receives only that area.
  ///   3. Sends cropped image to /detect, then /analyze. Only purple/transparent in ROI is accepted.
  ///
  /// Original and cropped temp files are deleted after use.
  Future<UvAnalysisResult?> captureAndAnalyse({
    required int fitzpatrickType,
    required int spf,
    // Default to 500 lux (overcast outdoor) — a conservative but realistic
    // value used for logging only; white balance runs independently.
    double ambientLux = 500.0,
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

    // ── Stage 1: Capture ────────────────────────────────────────────────────
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

/// MED baselines (J/m²) per Fitzpatrick type — mirrors backend MED_TABLE.
const Map<int, double> _medTable = {
  1: 200.0, 2: 250.0, 3: 350.0, 4: 500.0, 5: 700.0, 6: 1000.0,
};

final scanNotifierProvider =
    StateNotifierProvider.autoDispose<ScanNotifier, ScanState>((ref) {
  final homeState = ref.watch(homeNotifierProvider);
  final deps = ref.watch(analyzeStickerUseCaseProvider);
  final prefs = ref.read(sharedPreferencesProvider);

  int fitzpatrickType = 2;
  try {
    final raw = prefs.getString('skin_profile');
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      fitzpatrickType = (map['fitzpatrick_type'] as int?) ?? 2;
    }
  } catch (_) {}

  final medBaseline = _medTable[fitzpatrickType.clamp(1, 6)] ?? 250.0;
  final doseJm2 = (homeState.doseSummary?.medUsedFraction ?? 0.0) * medBaseline;
  final uvIdx = homeState.uvIndex?.value ?? 5.0;

  return ScanNotifier(
    deps: deps,
    currentDoseJm2: doseJm2,
    currentUvIndex: uvIdx,
  );
});
