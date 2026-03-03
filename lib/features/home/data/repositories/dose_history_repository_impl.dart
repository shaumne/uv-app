import 'package:dartz/dartz.dart';
import '../../../../core/constants/uv_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/daily_dose_summary.dart';
import '../../domain/repositories/dose_history_repository.dart';
import '../datasources/dose_history_local_datasource.dart';

class DoseHistoryRepositoryImpl implements DoseHistoryRepository {
  const DoseHistoryRepositoryImpl(this._datasource);
  final DoseHistoryLocalDatasource _datasource;

  @override
  Future<Either<Failure, DailyDoseSummary>> getTodaySummary(
    int fitzpatrickType,
  ) async {
    try {
      final cumDose = await _datasource.getTodayCumulativeDoseJm2();
      final medBase =
          UvConstants.medBaselineJoules[fitzpatrickType] ?? 300.0;

      // Approximate remaining minutes using average UV index 5
      final medFraction = (cumDose / medBase).clamp(0.0, 10.0);
      final remaining = medFraction >= 1.0
          ? 0
          : ((medBase - cumDose) /
                  (UvConstants.uvIrradiancePerIndex * 5.0) /
                  60)
              .toInt();

      return Right(
        DailyDoseSummary(
          medUsedFraction: medFraction,
          remainingMinutes: remaining.clamp(0, 999),
          date: DateTime.now(),
        ),
      );
    } on CacheException catch (e) {
      appLogger.e('[DoseHistoryRepo] CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveDoseRecord({
    required double cumulativeDoseJm2,
    required int fitzpatrickType,
  }) async {
    try {
      await _datasource.saveCumulativeDoseJm2(cumulativeDoseJm2);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
