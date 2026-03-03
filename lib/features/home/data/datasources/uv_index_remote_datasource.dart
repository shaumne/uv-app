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

/// Fetches UV index from currentuvindex.com (no API key required).
class UvIndexRemoteDatasourceImpl implements UvIndexRemoteDatasource {
  const UvIndexRemoteDatasourceImpl(this._dio);
  final Dio _dio;

  static const _baseUrl = 'https://currentuvindex.com/api/v1';

  @override
  Future<UvIndexModel> fetchUvIndex({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/uvi',
        queryParameters: {'lat': latitude, 'lng': longitude},
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      final data = response.data;
      if (data == null || response.statusCode != 200) {
        throw const ServerException(
          message: 'UV index service returned an empty response.',
        );
      }

      appLogger.d('[UvIndex] lat=$latitude lng=$longitude data=$data');
      return UvIndexModel.fromJson(data, latitude, longitude);
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
