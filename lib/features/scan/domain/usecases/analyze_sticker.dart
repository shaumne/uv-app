import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../result/domain/entities/uv_analysis_result.dart';
import '../entities/scan_request.dart';
import '../repositories/scan_repository.dart';

/// Orchestrates the sticker analysis pipeline.
///
/// Delegates the actual API call to [ScanRepository], keeping the
/// domain layer free of transport concerns.
class AnalyzeSticker {
  const AnalyzeSticker(this._repository);
  final ScanRepository _repository;

  Future<Either<Failure, UvAnalysisResult>> call(ScanRequest request) =>
      _repository.analyzeSticker(request);
}
