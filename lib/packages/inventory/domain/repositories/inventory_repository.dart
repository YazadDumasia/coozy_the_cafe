import '../entities/inventory_item.dart';

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
}
