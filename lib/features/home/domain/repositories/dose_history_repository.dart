import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/daily_dose_summary.dart';

abstract interface class DoseHistoryRepository {
  Future<Either<Failure, DailyDoseSummary>> getTodaySummary(int fitzpatrickType);
  Future<Either<Failure, Unit>> saveDoseRecord({
    required double cumulativeDoseJm2,
    required int fitzpatrickType,
  });
}
