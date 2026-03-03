import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/skin_profile.dart';

/// Contract for persisting and retrieving the user's skin profile.
abstract interface class SkinProfileRepository {
  /// Saves [profile] to local storage.
  Future<Either<Failure, Unit>> save(SkinProfile profile);

  /// Returns the stored [SkinProfile], or [CacheFailure] if none exists.
  Future<Either<Failure, SkinProfile>> load();

  /// Returns [true] if the user has completed onboarding.
  Future<bool> isOnboardingComplete();
}
