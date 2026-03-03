import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/uv_index.dart';
import '../repositories/uv_index_repository.dart';

class GetCurrentUvIndex {
  const GetCurrentUvIndex(this._repository);
  final UvIndexRepository _repository;

  Future<Either<Failure, UvIndex>> call({
    required double latitude,
    required double longitude,
  }) =>
      _repository.getCurrentUvIndex(latitude: latitude, longitude: longitude);
}
