import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/expenditure_entity.dart';
import '../entities/expenditure_category_entity.dart';
import '../repositories/expenditure_repository.dart';

class AddExpenditureUseCase {
  final ExpenditureRepository repository;

  AddExpenditureUseCase(this.repository);

  Future<Either<Failure, int>> call(ExpenditureEntity expenditure) {
    return repository.addExpenditure(expenditure);
  }
}

class DeleteExpenditureUseCase {
  final ExpenditureRepository repository;

  DeleteExpenditureUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.deleteExpenditure(id);
  }
}

class AddCustomCategoryUseCase {
  final ExpenditureRepository repository;

  AddCustomCategoryUseCase(this.repository);

  Future<Either<Failure, int>> call(ExpenditureCategoryEntity category) {
    return repository.addCategory(category);
  }
}
