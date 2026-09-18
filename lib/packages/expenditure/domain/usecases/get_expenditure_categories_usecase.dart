import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/expenditure_category_entity.dart';
import '../repositories/expenditure_repository.dart';

class GetExpenditureCategoriesUseCase {
  final ExpenditureRepository repository;

  GetExpenditureCategoriesUseCase(this.repository);

  Future<Either<Failure, List<ExpenditureCategoryEntity>>> call(String type) {
    return repository.getCategoriesByType(type);
  }

  Stream<Either<Failure, List<ExpenditureCategoryEntity>>> watch(String type) {
    return repository.watchCategoriesByType(type);
  }
}
