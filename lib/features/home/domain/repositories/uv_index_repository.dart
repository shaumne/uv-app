import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/uv_index.dart';

abstract interface class UvIndexRepository {
  /// Fetches current UV index for [latitude]/[longitude].
  Future<Either<Failure, UvIndex>> getCurrentUvIndex({
    required double latitude,
    required double longitude,
  });
}
