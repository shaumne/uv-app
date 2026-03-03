import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../../result/domain/entities/uv_analysis_result.dart';
import '../../domain/entities/scan_request.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_remote_datasource.dart';

class ScanRepositoryImpl implements ScanRepository {
  const ScanRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
    required this.cumulativeDoseJm2,
    required this.uvIndex,
    required this.hoursSinceApplication,
  });

  final ScanRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final double cumulativeDoseJm2;
  final double uvIndex;
  final double hoursSinceApplication;

  @override
  Future<Either<Failure, UvAnalysisResult>> analyzeSticker(
    ScanRequest request,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDatasource.analyzeSticker(
        request: request,
        cumulativeDoseJm2: cumulativeDoseJm2,
        uvIndex: uvIndex,
        hoursSinceApplication: hoursSinceApplication,
      );
      return Right(result);
    } on NetworkException catch (e) {
      appLogger.w('[ScanRepo] Network: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on ImageProcessingException catch (e) {
      appLogger.w('[ScanRepo] ImageProcessing: ${e.message}');
      return Left(ImageProcessingFailure(e.message));
    } on ServerException catch (e) {
      appLogger.e('[ScanRepo] Server: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      appLogger.e('[ScanRepo] Unknown error', error: e, stackTrace: st);
      return const Left(UnknownFailure());
    }
  }
}
