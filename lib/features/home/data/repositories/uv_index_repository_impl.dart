import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/uv_index.dart';
import '../../domain/repositories/uv_index_repository.dart';
import '../datasources/uv_index_remote_datasource.dart';

class UvIndexRepositoryImpl implements UvIndexRepository {
  const UvIndexRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final UvIndexRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, UvIndex>> getCurrentUvIndex({
    required double latitude,
    required double longitude,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = await remoteDatasource.fetchUvIndex(
        latitude: latitude,
        longitude: longitude,
      );
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      appLogger.w('[UvIndexRepo] NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      appLogger.e('[UvIndexRepo] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    }
  }
}
