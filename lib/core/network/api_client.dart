import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../error/exceptions.dart';

/// Singleton Dio HTTP client with interceptors.
///
/// Handles:
/// - Base URL and timeout configuration
/// - Request/response logging (debug only, stripped in release)
/// - Uniform error mapping to [ServerException] / [NetworkException]
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Accept': 'application/json',
          'X-Client': 'uv-dosimeter-flutter',
        },
      ),
    )
      ..interceptors.add(_LoggingInterceptor())
      ..interceptors.add(_ErrorInterceptor());
  }

  static final ApiClient instance = ApiClient._();
  late final Dio _dio;

  Dio get dio => _dio;
}

/// Logs requests and responses at DEBUG level.
/// In release mode [Logger] automatically suppresses output.
class _LoggingInterceptor extends Interceptor {
  final _log = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: true),
    level: Level.debug,
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.d('[→] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _log.d('[←] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.e('[✗] ${err.type}: ${err.message}');
    handler.next(err);
  }
}

/// Passes all errors through unchanged so each datasource can classify
/// them by status code (422 vs 5xx) and exception type individually.
///
/// Note: a global interceptor that converts badResponse → ServerException
/// would strip the [DioException.response] object, preventing datasources
/// from distinguishing 422 (sticker-not-found) from 500 (server crash).
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
