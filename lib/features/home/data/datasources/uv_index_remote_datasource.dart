import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/uv_index_model.dart';

abstract interface class UvIndexRemoteDatasource {
  Future<UvIndexModel> fetchUvIndex({
    required double latitude,
    required double longitude,
  });
}

/// Fetches UV index from Open-Meteo (free, no API key required).
///
/// Endpoint: https://api.open-meteo.com/v1/forecast
/// Returns hourly `uv_index` forecast for the current day.
/// We pick the value for the current hour as the real-time reading.
class UvIndexRemoteDatasourceImpl implements UvIndexRemoteDatasource {
  const UvIndexRemoteDatasourceImpl(this._dio);
  final Dio _dio;

  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  @override
  Future<UvIndexModel> fetchUvIndex({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Use a dedicated Dio instance with the Open-Meteo base URL so this
      // call bypasses the app's internal FastAPI base URL entirely.
      final openMeteoDio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
      ));
      final response = await openMeteoDio.get<Map<String, dynamic>>(
        '',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'hourly': 'uv_index',
          'forecast_days': 1,
          'timezone': 'auto',
        },
      );

      final data = response.data;
      if (data == null || response.statusCode != 200) {
        throw const ServerException(
          message: 'UV index service returned an empty response.',
        );
      }

      appLogger.d('[UvIndex] lat=$latitude lng=$longitude');
      return UvIndexModel.fromOpenMeteoJson(data, latitude, longitude);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException(message: 'Cannot reach UV index service.');
      }
      throw ServerException(
        message: e.response?.data?.toString() ?? e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
