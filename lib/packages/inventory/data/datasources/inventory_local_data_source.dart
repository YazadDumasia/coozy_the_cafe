import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart' as db;
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

  @override
  Future<List<InventoryItemModel>> getInventoryItems() async {
    final query = database.select(database.inventoryTable);
    final results = await query.get();
    return results.map((e) => InventoryItemModel.fromData(e)).toList();
  }

  @override
  Future<List<InventoryItemModel>> getInventoryItemsPaged(
    int limit,
    int offset,
    String? search,
  ) async {
    final query = database.select(database.inventoryTable);
    if (search != null && search.isNotEmpty) {
      query.where((t) => t.name.like('%$search%'));
    }
    query.limit(limit, offset: offset);
    final results = await query.get();
    return results.map((e) => InventoryItemModel.fromData(e)).toList();
  }

  @override
  Future<InventoryItemModel?> getInventoryItemById(int id) async {
    final query = database.select(database.inventoryTable)
      ..where((t) => t.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? InventoryItemModel.fromData(result) : null;
  }

  @override
  Future<int> insertInventoryItem(InventoryItemModel item) async {
    return await database
        .into(database.inventoryTable)
        .insert(item.toCompanion());
  }

  @override
  Future<bool> updateInventoryItem(InventoryItemModel item) async {
    return await database
        .update(database.inventoryTable)
        .replace(item.toCompanion());
  }

  @override
  Future<bool> deleteInventoryItem(int id) async {
    final deletedRows = await (database.delete(
      database.inventoryTable,
    )..where((t) => t.id.equals(id))).go();
    return deletedRows > 0;
  }
}
