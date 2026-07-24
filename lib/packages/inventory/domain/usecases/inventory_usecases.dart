import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class GetInventoryItemsUseCase {
  final InventoryRepository repository;
  GetInventoryItemsUseCase(this.repository);

  Future<List<InventoryItem>> call() async {
    return await repository.getInventoryItems();
  }
}

class GetInventoryItemsPagedUseCase {
  final InventoryRepository repository;
  GetInventoryItemsPagedUseCase(this.repository);

  Future<List<InventoryItem>> call(
    int limit,
    int offset,
    String? search,
  ) async {
    return await repository.getInventoryItemsPaged(limit, offset, search);
  }
}

class AddInventoryItemUseCase {
  final InventoryRepository repository;
  AddInventoryItemUseCase(this.repository);

  Future<int> call(InventoryItem item) async {
    return await repository.addInventoryItem(item);
  }
}

class UpdateInventoryItemUseCase {
  final InventoryRepository repository;
  UpdateInventoryItemUseCase(this.repository);

  Future<bool> call(InventoryItem item) async {
    return await repository.updateInventoryItem(item);
  }
}

class DeleteInventoryItemUseCase {
  final InventoryRepository repository;
  DeleteInventoryItemUseCase(this.repository);

  Future<bool> call(int id) async {
    return await repository.deleteInventoryItem(id);
  }
}
