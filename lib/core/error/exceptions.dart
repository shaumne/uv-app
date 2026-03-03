/// Data-layer exceptions — caught inside repository implementations
/// and mapped to the corresponding [Failure] subclass before crossing
/// into the domain layer.
class ServerException implements Exception {
  const ServerException({this.message = 'Server error.', this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException({this.message = 'Network unreachable.'});
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class CameraException implements Exception {
  const CameraException({this.message = 'Camera error.'});
  final String message;

  @override
  String toString() => 'CameraException: $message';
}

class CacheException implements Exception {
  const CacheException({this.message = 'Cache error.'});
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class ImageProcessingException implements Exception {
  const ImageProcessingException({this.message = 'Image processing failed.'});
  final String message;

  @override
  String toString() => 'ImageProcessingException: $message';
}
