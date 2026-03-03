import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/skin_profile.dart';
import '../../domain/repositories/skin_profile_repository.dart';
import '../datasources/skin_profile_local_datasource.dart';
import '../models/skin_profile_model.dart';

class SkinProfileRepositoryImpl implements SkinProfileRepository {
  const SkinProfileRepositoryImpl(this._datasource);
  final SkinProfileLocalDatasource _datasource;

  @override
  Future<Either<Failure, Unit>> save(SkinProfile profile) async {
    try {
      await _datasource.save(SkinProfileModel.fromEntity(profile));
      return const Right(unit);
    } on CacheException catch (e) {
      appLogger.e('SkinProfileRepository.save', error: e);
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SkinProfile>> load() async {
    try {
      final model = await _datasource.load();
      return Right(model.toEntity());
    } on CacheException catch (e) {
      appLogger.w('SkinProfileRepository.load — no profile stored: $e');
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<bool> isOnboardingComplete() =>
      _datasource.isOnboardingComplete();
}
