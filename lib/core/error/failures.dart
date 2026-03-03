import 'package:equatable/equatable.dart';

/// Sealed hierarchy of domain-level failures.
///
/// Use [Either<Failure, T>] (from dartz) as the return type of all
/// repository and use-case methods to enforce explicit error handling
/// without throwing exceptions across layer boundaries.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

/// No internet / host unreachable.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// FastAPI backend returned a non-2xx response.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

/// Camera permission was denied or hardware unavailable.
final class CameraFailure extends Failure {
  const CameraFailure([super.message = 'Camera access denied or unavailable.']);
}

/// Location permission denied or GPS off.
final class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Location access denied or unavailable.']);
}

/// Image could not be read, decoded, or is too small for analysis.
final class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure([super.message = 'Image could not be processed.']);
}

/// Local persistence (Hive / SharedPrefs) read-write error.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data error.']);
}

/// Unexpected / uncategorised error.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
