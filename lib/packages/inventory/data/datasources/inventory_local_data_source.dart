import 'package:coozy_the_cafe/packages/database/coozy_database.dart' as db;
import '../models/inventory_item_model.dart';

abstract class InventoryLocalDataSource {
  Future<List<InventoryItemModel>> getInventoryItems();
  Future<List<InventoryItemModel>> getInventoryItemsPaged(
    int limit,
    int offset,
    String? search,
  );
  Future<InventoryItemModel?> getInventoryItemById(int id);
  Future<int> insertInventoryItem(InventoryItemModel item);
  Future<bool> updateInventoryItem(InventoryItemModel item);
  Future<bool> deleteInventoryItem(int id);
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final db.CoozyDatabase database;

  InventoryLocalDataSourceImpl({required this.database});

  db.InventoryDao get _inventoryDao => database.inventoryDao;

  @override
  Future<List<InventoryItemModel>> getInventoryItems() async {
    final results = await _inventoryDao.getAllInventory();
    return results.map((e) => InventoryItemModel.fromData(e)).toList();
  }

  @override
  Future<List<InventoryItemModel>> getInventoryItemsPaged(
    int limit,
    int offset,
    String? search,
  ) async {
    final page = limit > 0 ? offset ~/ limit : 0;
    final results = await _inventoryDao.getInventoryPage(
      page: page,
      pageSize: limit,
      searchQuery: search,
    );
    return results.map((e) => InventoryItemModel.fromData(e)).toList();
  }

  @override
  Future<InventoryItemModel?> getInventoryItemById(int id) async {
    final result = await _inventoryDao.getInventoryById(id);
    return result != null ? InventoryItemModel.fromData(result) : null;
  }

  @override
  Future<int> insertInventoryItem(InventoryItemModel item) async {
    return await _inventoryDao.insertInventory(item.toCompanion());
  }

  @override
  Future<bool> updateInventoryItem(InventoryItemModel item) async {
    final result = await _inventoryDao.updateInventory(item.toCompanion());
    return result > 0;
  }

  @override
  Future<bool> deleteInventoryItem(int id) async {
    final deletedRows = await _inventoryDao.deleteInventory(id);
    return deletedRows > 0;
  }
}
