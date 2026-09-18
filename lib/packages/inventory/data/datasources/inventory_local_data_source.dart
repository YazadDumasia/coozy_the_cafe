import 'package:coozy_the_cafe/packages/database/coozy_database.dart' as db;
import '../models/inventory_item_model.dart';
import '../models/stock_adjustment_model.dart';

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
  Future<bool> adjustStock({
    required int inventoryId,
    required double adjustedQty,
    required bool isIncrement,
    String? reason,
  });
  Future<List<StockAdjustmentModel>> getStockAdjustments({
    int? inventoryId,
    String? fromDate,
    String? toDate,
  });
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

  @override
  Future<bool> adjustStock({
    required int inventoryId,
    required double adjustedQty,
    required bool isIncrement,
    String? reason,
  }) async {
    return await _inventoryDao.adjustInventoryStock(
      inventoryId: inventoryId,
      adjustedQty: adjustedQty,
      isIncrement: isIncrement,
      reason: reason,
    );
  }

  @override
  Future<List<StockAdjustmentModel>> getStockAdjustments({
    int? inventoryId,
    String? fromDate,
    String? toDate,
  }) async {
    List<db.InventoryStockAdjustment> results;
    if (inventoryId != null) {
      results = await _inventoryDao.getStockAdjustmentsByInventoryId(
        inventoryId,
      );
    } else if (fromDate != null && toDate != null) {
      results = await _inventoryDao.getStockAdjustmentsBetweenDates(
        fromDateTime: fromDate,
        toDateTime: toDate,
      );
    } else {
      results = await _inventoryDao.getAllStockAdjustments();
    }
    return results.map((e) => StockAdjustmentModel.fromData(e)).toList();
  }
}
