import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/repositories/dose_history_repository.dart';

/// Persists the updated cumulative dose after a successful scan.
class SaveDoseRecord {
  const SaveDoseRecord(this._repository);
  final DoseHistoryRepository _repository;

  Future<Either<Failure, Unit>> call({
    required double cumulativeDoseJm2,
    required int fitzpatrickType,
  }) =>
      _repository.saveDoseRecord(
        cumulativeDoseJm2: cumulativeDoseJm2,
        fitzpatrickType: fitzpatrickType,
      );
}
