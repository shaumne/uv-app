import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../result/domain/entities/uv_analysis_result.dart';
import '../models/scan_request_model.dart';
import '../../domain/entities/scan_request.dart';

/// Result of a lightweight sticker presence check.
class StickerDetectionResult {
  const StickerDetectionResult({
    required this.detected,
    required this.confidence,
    this.reason,
  });

  final bool detected;

  /// 0.0 – 1.0 detection confidence.
  final double confidence;

  /// Rejection reason code when [detected] is false.
  final String? reason;
}

abstract interface class ScanRemoteDatasource {
  Future<UvAnalysisResult> analyzeSticker({required ScanRequest request});

  /// Lightweight check — returns detection result without full MED analysis.
  /// [ambientLux] is used for adaptive HSV mask on the backend (optional; default 1000).
  Future<StickerDetectionResult> detectSticker({
    required String imagePath,
    double? ambientLux,
  });
}

class ScanRemoteDatasourceImpl implements ScanRemoteDatasource {
  const ScanRemoteDatasourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<UvAnalysisResult> analyzeSticker({
    required ScanRequest request,
  }) async {
    FormData formData;
    try {
      formData = await ScanRequestModel.toFormData(request);
    } catch (e) {
      throw ImageProcessingException(
        message: 'Failed to prepare image for upload: $e',
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.analyzeSticker,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data == null) {
        throw const ServerException(message: 'Empty response from analysis API.');
      }

      appLogger.d('[ScanDatasource] Response: $data');
      return _mapToEntity(data);
    } on DioException catch (e) {
      final body = e.response?.data;
      final detail = body is Map ? body['detail'] ?? '' : '';

      // Map server-side 422 error codes from colorimetry_service to client failures
      if (e.response?.statusCode == 422) {
        throw ImageProcessingException(message: detail.toString());
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(message: e.message ?? 'Network unreachable.');
      }
      throw ServerException(
        message: detail.toString().isNotEmpty ? detail.toString() : 'Analysis failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<StickerDetectionResult> detectSticker({
    required String imagePath,
    double? ambientLux,
  }) async {
    FormData formData;
    try {
      final map = <String, dynamic>{
        ApiConstants.fieldImage: await MultipartFile.fromFile(imagePath),
        'pre_cropped': 'true', // Client sends only the guide ROI
      };
      if (ambientLux != null) {
        map['ambient_lux'] = ambientLux;
      }
      formData = FormData.fromMap(map);
    } catch (e) {
      appLogger.w('[ScanDatasource] detect: failed to read image file: $e');
      throw ImageProcessingException(message: 'Failed to read captured image: $e');
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.detectSticker,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          // Image upload + OpenCV processing can take 15–25 s on device.
          // Use generous timeouts here rather than the global 30 s default
          // so that the detect step never races the analyse step's timeout.
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException(message: 'Empty response from detect API.');
      }
      appLogger.d('[ScanDatasource] detect response: $data');
      return StickerDetectionResult(
        detected: data['detected'] as bool? ?? false,
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
        reason: data['reason'] as String?,
      );
    } on DioException catch (e) {
      appLogger.e('[ScanDatasource] detect DioException: ${e.type}', error: e);

      // Network / connectivity failures must bubble up so the caller can show
      // a "no connection" error — NOT be silenced as "sticker not detected".
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(
          message: 'No connection to server. Check your Wi-Fi and that the backend is running.',
        );
      }
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          message: 'Server took too long to respond. Check network speed and backend load.',
        );
      }

      // 4xx/5xx responses that carry a structured detail message.
      final body = e.response?.data;
      final detail = body is Map ? (body['detail'] ?? '').toString() : '';
      if (e.response?.statusCode == 422) {
        throw ImageProcessingException(message: detail.isNotEmpty ? detail : 'Detection failed.');
      }
      throw ServerException(
        message: detail.isNotEmpty ? detail : 'Detection request failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Maps raw API JSON to [UvAnalysisResult] domain entity.
  UvAnalysisResult _mapToEntity(Map<String, dynamic> json) {
    return UvAnalysisResult(
      hexColor: json['hex_color'] as String,
      uvPercent: (json['uv_percent'] as num).toDouble(),
      // dose_percentage on the backend is explicitly set to the sticker's
      // UV% reading, not SPF-adjusted MED fraction. Using it here keeps the
      // user-facing "daily limit used" copy aligned with sticker colour.
      medUsedFraction: (json['dose_percentage'] as num).toDouble() / 100.0,
      remainingMinutes: (json['minutes_remaining'] as num).toInt(),
      riskLevel: json['risk_level'] as String,
      spfEffectiveNow: (json['spf_effective_now'] as num).toDouble(),
      sunscreenReapplyRecommended:
          json['sunscreen_reapply_recommended'] as bool? ?? false,
      analyzedAt: DateTime.now(),
      cumulativeDoseJm2:
          (json['cumulative_dose_jm2'] as num?)?.toDouble() ?? 0.0,
      stickerDoseJm2:
          (json['sticker_dose_jm2'] as num?)?.toDouble() ??
              (json['cumulative_dose_jm2'] as num?)?.toDouble() ??
              0.0,
      previousCumulativeDoseJm2:
          (json['previous_cumulative_dose_jm2'] as num?)?.toDouble() ??
              (json['cumulative_dose_jm2'] as num?)?.toDouble() ??
              0.0,
      stickerResetSuspected:
          json['sticker_reset_suspected'] as bool? ?? false,
    );
  }
}
