import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/expenditure_entity.dart';
import '../repositories/expenditure_repository.dart';

class GetExpendituresByDateRangeUseCase {
  final ExpenditureRepository repository;

  GetExpendituresByDateRangeUseCase(this.repository);

  Future<Either<Failure, List<ExpenditureEntity>>> call({
    required DateTime startDate,
    required DateTime endDate,
    String? type,
    int? limit,
    int? offset,
  }) {
    return repository.getExpendituresByDateRange(
      startDate: startDate,
      endDate: endDate,
      type: type,
      limit: limit,
      offset: offset,
    );
  }

  Stream<Either<Failure, List<ExpenditureEntity>>> watch({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.watchExpendituresByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
