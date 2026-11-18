import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';

import '../entities/combo.dart';
import '../repositories/combo_repository.dart';

class GetCombosUseCase {
  final ComboRepository repository;

  GetCombosUseCase(this.repository);

  Future<Either<Failure, List<Combo>>> call({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  }) {
    return repository.getCombos(
      searchQuery: searchQuery,
      onlyActive: onlyActive,
      limit: limit,
      offset: offset,
    );
  }
}

class WatchCombosUseCase {
  final ComboRepository repository;

  WatchCombosUseCase(this.repository);

  Stream<Either<Failure, List<Combo>>> call({
    String? searchQuery,
    bool? onlyActive,
    int? limit,
    int? offset,
  }) {
    return repository.watchCombos(
      searchQuery: searchQuery,
      onlyActive: onlyActive,
      limit: limit,
      offset: offset,
    );
  }
}

class CreateComboUseCase {
  final ComboRepository repository;

  CreateComboUseCase(this.repository);

  Future<Either<Failure, int>> call(Combo combo) {
    return repository.createCombo(combo);
  }
}

class UpdateComboUseCase {
  final ComboRepository repository;

  UpdateComboUseCase(this.repository);

  Future<Either<Failure, bool>> call(Combo combo) {
    return repository.updateCombo(combo);
  }
}

class DeleteComboUseCase {
  final ComboRepository repository;

  DeleteComboUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.deleteCombo(id);
  }
}

class ToggleComboStatusUseCase {
  final ComboRepository repository;

  ToggleComboStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id, bool isActive) {
    return repository.toggleComboStatus(id, isActive);
  }
}

class SearchMenuItemsForComboUseCase {
  final ComboRepository repository;

  SearchMenuItemsForComboUseCase(this.repository);

  Future<Either<Failure, List<MenuItem>>> call({
    String? searchQuery,
    int? limit,
    int? offset,
  }) {
    return repository.searchMenuItems(
      searchQuery: searchQuery,
      limit: limit,
      offset: offset,
    );
  }
}

class GetMenuItemsCountForComboUseCase {
  final ComboRepository repository;

  GetMenuItemsCountForComboUseCase(this.repository);

  Future<Either<Failure, int>> call({String? searchQuery}) {
    return repository.getMenuItemsCount(searchQuery: searchQuery);
  }
}

class UpdateComboSortOrdersUseCase {
  final ComboRepository repository;

  UpdateComboSortOrdersUseCase(this.repository);

  Future<Either<Failure, void>> call(List<Combo> combos) {
    return repository.updateComboSortOrders(combos);
  }
}
