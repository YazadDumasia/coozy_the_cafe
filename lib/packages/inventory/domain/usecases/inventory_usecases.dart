import '../entities/inventory_item.dart';
import '../entities/stock_adjustment.dart';
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

class AdjustInventoryStockUseCase {
  final InventoryRepository repository;
  AdjustInventoryStockUseCase(this.repository);

  Future<bool> call({
    required int inventoryId,
    required double adjustedQty,
    required bool isIncrement,
    String? reason,
  }) async {
    return await repository.adjustStock(
      inventoryId: inventoryId,
      adjustedQty: adjustedQty,
      isIncrement: isIncrement,
      reason: reason,
    );
  }
}

class GetStockAdjustmentsUseCase {
  final InventoryRepository repository;
  GetStockAdjustmentsUseCase(this.repository);

  Future<List<StockAdjustment>> call({
    int? inventoryId,
    String? fromDate,
    String? toDate,
  }) async {
    return await repository.getStockAdjustments(
      inventoryId: inventoryId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
