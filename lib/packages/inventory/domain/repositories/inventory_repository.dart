import '../entities/inventory_item.dart';
import '../entities/stock_adjustment.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventoryItems();
  Future<List<InventoryItem>> getInventoryItemsPaged(
    int limit,
    int offset,
    String? search,
  );
  Future<InventoryItem?> getInventoryItemById(int id);
  Future<int> addInventoryItem(InventoryItem item);
  Future<bool> updateInventoryItem(InventoryItem item);
  Future<bool> deleteInventoryItem(int id);
  Future<bool> adjustStock({
    required int inventoryId,
    required double adjustedQty,
    required bool isIncrement,
    String? reason,
  });
  Future<List<StockAdjustment>> getStockAdjustments({
    int? inventoryId,
    String? fromDate,
    String? toDate,
  });
}
