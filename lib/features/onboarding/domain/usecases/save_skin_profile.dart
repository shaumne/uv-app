import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/skin_profile.dart';
import '../repositories/skin_profile_repository.dart';

/// Persists the user's [SkinProfile] after onboarding completion.
///
/// Single-responsibility use case — delegates storage to [SkinProfileRepository].
class SaveSkinProfile {
  const SaveSkinProfile(this._repository);
  final SkinProfileRepository _repository;

  Future<Either<Failure, Unit>> call(SkinProfile profile) =>
      _repository.save(profile);
}
