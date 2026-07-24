import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart' as db;
import '../models/purchase_record_model.dart';

abstract class PurchaseLocalDataSource {
  Future<List<PurchaseRecordModel>> getPurchasesForInventoryItem(
    int inventoryId,
  );
  Future<List<PurchaseRecordModel>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<PurchaseRecordModel>> getAllPurchasesPaged(
    int limit,
    int offset,
    String? search,
  );
  Future<int> insertPurchaseRecord(PurchaseRecordModel record);
  Future<int> updatePurchaseRecord(PurchaseRecordModel record);
  Future<int> deletePurchaseRecord(int id);
}

class PurchaseLocalDataSourceImpl implements PurchaseLocalDataSource {
  final db.CoozyDatabase database;

  PurchaseLocalDataSourceImpl({required this.database});

  @override
  Future<List<PurchaseRecordModel>> getPurchasesForInventoryItem(
    int inventoryId,
  ) async {
    final query = database.select(database.purchaseTable)
      ..where((t) => t.inventoryId.equals(inventoryId))
      ..orderBy([
        (t) => OrderingTerm(
          expression: t.purchaseDateTime,
          mode: OrderingMode.desc,
        ),
      ]);
    final results = await query.get();
    return results.map((e) => PurchaseRecordModel.fromData(e)).toList();
  }

  @override
  Future<List<PurchaseRecordModel>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    final query = database.select(database.purchaseTable)
      ..where((t) => t.purchaseDateTime.isBetweenValues(startStr, endStr));

    final results = await query.get();
    return results.map((r) => PurchaseRecordModel.fromData(r)).toList();
  }

  @override
  Future<List<PurchaseRecordModel>> getAllPurchasesPaged(
    int limit,
    int offset,
    String? search,
  ) async {
    final query = database.select(database.purchaseTable)
      ..orderBy([
        (t) => OrderingTerm(
          expression: t.purchaseDateTime,
          mode: OrderingMode.desc,
        ),
      ]);

    if (search != null && search.isNotEmpty) {
      query.where((t) => t.name.like('%$search%'));
    }

    query.limit(limit, offset: offset);
    final results = await query.get();
    return results.map((e) => PurchaseRecordModel.fromData(e)).toList();
  }

  @override
  Future<int> insertPurchaseRecord(PurchaseRecordModel record) async {
    return await database.transaction(() async {
      // 1. Insert the purchase record
      final purchaseId = await database
          .into(database.purchaseTable)
          .insert(record.toCompanion());

      // 2. Update the corresponding inventory item's stock
      if (record.inventoryId != null && record.purchaseQty != null) {
        final itemQuery = database.select(database.inventoryTable)
          ..where((t) => t.id.equals(record.inventoryId!));
        final item = await itemQuery.getSingleOrNull();
        if (item != null) {
          final currentStock = item.currentStock ?? 0.0;
          final newStock = currentStock + record.purchaseQty!;

          final updateCompanion = db.InventoryTableCompanion(
            id: Value(item.id),
            currentStock: Value(newStock),
            modifiedDate: Value(DateTime.now().toIso8601String()),
          );

          await (database.update(
            database.inventoryTable,
          )..where((t) => t.id.equals(item.id))).write(updateCompanion);
        }
      }
      return purchaseId;
    });
  }

  @override
  Future<int> updatePurchaseRecord(PurchaseRecordModel record) async {
    return await database.transaction(() async {
      // 1. Fetch old record
      final oldRecordQuery = database.select(database.purchaseTable)
        ..where((t) => t.id.equals(record.id!));
      final oldRecord = await oldRecordQuery.getSingleOrNull();

      if (oldRecord != null) {
        // 2. Revert old stock impact and apply new stock impact
        final oldQty = oldRecord.purchaseQty ?? 0.0;
        final newQty = record.purchaseQty ?? 0.0;
        final qtyDelta = newQty - oldQty;

        if (record.inventoryId != null && qtyDelta != 0.0) {
          final itemQuery = database.select(database.inventoryTable)
            ..where((t) => t.id.equals(record.inventoryId!));
          final item = await itemQuery.getSingleOrNull();
          if (item != null) {
            final currentStock = item.currentStock ?? 0.0;
            final updatedStock = currentStock + qtyDelta;
            await database
                .update(database.inventoryTable)
                .replace(item.copyWith(currentStock: Value(updatedStock)));
          }
        }
      }

      // 3. Update the purchase record
      await database
          .update(database.purchaseTable)
          .replace(record.toCompanion());
      return record.id!;
    });
  }

  @override
  Future<int> deletePurchaseRecord(int id) async {
    return await database.transaction(() async {
      // 1. Fetch record to know how much to revert
      final recordQuery = database.select(database.purchaseTable)
        ..where((t) => t.id.equals(id));
      final record = await recordQuery.getSingleOrNull();

      if (record != null) {
        // 2. Revert the stock
        final qty = record.purchaseQty ?? 0.0;
        if (record.inventoryId != null && qty != 0.0) {
          final itemQuery = database.select(database.inventoryTable)
            ..where((t) => t.id.equals(record.inventoryId!));
          final item = await itemQuery.getSingleOrNull();
          if (item != null) {
            final currentStock = item.currentStock ?? 0.0;
            final updatedStock = currentStock - qty;
            await database
                .update(database.inventoryTable)
                .replace(item.copyWith(currentStock: Value(updatedStock)));
          }
        }
      }

      // 3. Delete the purchase record
      return await (database.delete(
        database.purchaseTable,
      )..where((t) => t.id.equals(id))).go();
    });
  }
}
