import 'package:permission_handler/permission_handler.dart';
import '../error/failures.dart';
import 'package:dartz/dartz.dart';

/// Handles runtime permission requests for camera and location.
///
/// Returns [Either<Failure, Unit>] so callers can handle denial
/// without catching exceptions.
class PermissionService {
  const PermissionService();

  /// Requests camera permission and returns the result.
  Future<Either<Failure, Unit>> requestCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return const Right(unit);
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return const Left(CameraFailure('Camera permission denied.'));
  }

  /// Requests location (while-in-use) permission and returns the result.
  Future<Either<Failure, Unit>> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) return const Right(unit);
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return const Left(LocationFailure('Location permission denied.'));
  }

  /// Returns true if camera permission is currently granted.
  Future<bool> get isCameraGranted => Permission.camera.isGranted;

  /// Returns true if location permission is currently granted.
  Future<bool> get isLocationGranted => Permission.locationWhenInUse.isGranted;
}
