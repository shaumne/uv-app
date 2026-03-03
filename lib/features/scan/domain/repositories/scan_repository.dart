import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../result/domain/entities/uv_analysis_result.dart';
import '../entities/scan_request.dart';

abstract interface class ScanRepository {
  Future<Either<Failure, UvAnalysisResult>> analyzeSticker(ScanRequest request);
}
