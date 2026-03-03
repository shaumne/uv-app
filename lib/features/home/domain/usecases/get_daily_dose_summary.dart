import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/daily_dose_summary.dart';
import '../repositories/dose_history_repository.dart';

class GetDailyDoseSummary {
  const GetDailyDoseSummary(this._repository);
  final DoseHistoryRepository _repository;

  Future<Either<Failure, DailyDoseSummary>> call(int fitzpatrickType) =>
      _repository.getTodaySummary(fitzpatrickType);
}
