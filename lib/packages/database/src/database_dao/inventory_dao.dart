import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'inventory_dao.g.dart';

@DriftAccessor(tables: [InventoryTable, PurchaseTable])
class InventoryDao extends DatabaseAccessor<CoozyDatabase>
    with _$InventoryDaoMixin {
  InventoryDao(super.db);

  // ---- INVENTORY ----

  Future<int> insertInventory(InventoryTableCompanion inventory) async {
    return await transaction(() async {
      return await into(inventoryTable).insert(inventory);
    });
  }

  Future<int> updateInventory(InventoryTableCompanion inventory) async {
    return await transaction(() async {
      await update(inventoryTable).replace(inventory);
      return 1;
    });
  }

  Future<int> deleteInventory(int id) async {
    return await transaction(() async {
      await (update(purchaseTable)..where((t) => t.inventoryId.equals(id)))
          .write(const PurchaseTableCompanion(inventoryId: Value(null)));
      return await (delete(inventoryTable)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> insertInventoryBatch(List<InventoryTableCompanion> items) async {
    await transaction(() async {
      for (final item in items) {
        await into(inventoryTable).insert(item);
      }
    });
  }

  Future<void> updateInventoryBatch(List<InventoryTableCompanion> items) async {
    await transaction(() async {
      for (final item in items) {
        await update(inventoryTable).replace(item);
      }
    });
  }

  Future<void> deleteInventoryBatch(List<int> ids) async {
    await transaction(() async {
      for (final id in ids) {
        await (delete(inventoryTable)..where((t) => t.id.equals(id))).go();
      }
    });
  }

  Future<List<InventoryItem>> getAllEnableInventory() async {
    final query = select(inventoryTable)
      ..where((t) => t.isEnabled.equals(true));
    return await (query..orderBy([
          (t) =>
              OrderingTerm(expression: t.name.lower(), mode: OrderingMode.asc),
        ]))
        .get();
  }

  Future<List<InventoryItem>> getAllEnableInventoryPage({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    final query = select(inventoryTable)
      ..where((t) => t.isEnabled.equals(true));

    query
      ..orderBy([
        (t) => OrderingTerm(expression: t.name.lower(), mode: OrderingMode.asc),
      ])
      ..limit(pageSize, offset: page * pageSize);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final pattern = '%${searchQuery.toLowerCase()}%';
      query.where(
        (t) =>
            t.name.lower().like(pattern) |
            t.shortDescription.lower().like(pattern),
      );
    }

    return await query.get();
  }

  Future<List<InventoryItem>> searchInventoryByNameOrDescription({
    required String query,
  }) async {
    final pattern = '%${query.toLowerCase()}%';
    final stmt = select(inventoryTable)
      ..where(
        (t) =>
            t.name.lower().like(pattern) |
            t.shortDescription.lower().like(pattern),
      );
    return await (stmt..orderBy([
          (t) =>
              OrderingTerm(expression: t.name.lower(), mode: OrderingMode.asc),
        ]))
        .get();
  }

  Future<List<InventoryItem>> searchInventoryByNameOrDescriptionPage({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    final pattern = '%${query.toLowerCase()}%';
    final stmt = select(inventoryTable)
      ..where(
        (t) =>
            t.name.lower().like(pattern) |
            t.shortDescription.lower().like(pattern),
      );
    return await (stmt
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.name.lower(),
              mode: OrderingMode.asc,
            ),
          ])
          ..limit(pageSize, offset: page * pageSize))
        .get();
  }

  Future<int> getInventorySearchCount({required String searchQuery}) async {
    final pattern = '%${searchQuery.toLowerCase()}%';
    final countExp = inventoryTable.id.count();
    final query = selectOnly(inventoryTable)..addColumns([countExp]);
    query.where(
      inventoryTable.name.lower().like(pattern) |
          inventoryTable.shortDescription.lower().like(pattern),
    );
    return await query.map((row) => row.read(countExp)).getSingle() ?? 0;
  }

  Future<InventoryItem?> getInventoryById(int id) async {
    final query = select(inventoryTable)..where((t) => t.id.equals(id));
    return await query.getSingleOrNull();
  }

  Stream<InventoryItem?> watchInventoryById(int id) {
    final query = select(inventoryTable)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull();
  }

  Future<List<InventoryItem>> getAllInventory() async {
    final query = select(inventoryTable);
    return await (query..orderBy([
          (t) =>
              OrderingTerm(expression: t.name.lower(), mode: OrderingMode.asc),
        ]))
        .get();
  }

  Future<List<InventoryItem>> getInventoryPage({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    final query = select(inventoryTable);
    query
      ..orderBy([
        (t) => OrderingTerm(expression: t.name.lower(), mode: OrderingMode.asc),
      ])
      ..limit(pageSize, offset: page * pageSize);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final pattern = '%${searchQuery.toLowerCase()}%';
      query.where(
        (t) =>
            t.name.lower().like(pattern) |
            t.shortDescription.lower().like(pattern),
      );
    }

    return await query.get();
  }

  Future<List<String>> getEnabledInventoryFirstLetters({
    String? searchQuery,
  }) async {
    final firstLetterExp = CustomExpression<String>(
      'UPPER(SUBSTR(${inventoryTable.actualTableName}.${inventoryTable.name.name}, 1, 1))',
    );

    final query = selectOnly(inventoryTable, distinct: true)
      ..addColumns([firstLetterExp]);

    query.where(inventoryTable.isEnabled.equals(true));

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final pattern = '%${searchQuery.toLowerCase()}%';
      query.where(
        inventoryTable.name.lower().like(pattern) |
            inventoryTable.shortDescription.lower().like(pattern),
      );
    }

    query.orderBy([
      OrderingTerm(expression: firstLetterExp, mode: OrderingMode.asc),
    ]);

    final results = await query.map((row) => row.read(firstLetterExp)).get();
    return results.whereType<String>().toList();
  }

  Future<List<String>> getAllInventoryFirstLetters({
    String? searchQuery,
  }) async {
    final firstLetterExp = CustomExpression<String>(
      'UPPER(SUBSTR(${inventoryTable.actualTableName}.${inventoryTable.name.name}, 1, 1))',
    );

    final query = selectOnly(inventoryTable, distinct: true)
      ..addColumns([firstLetterExp]);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final pattern = '%${searchQuery.toLowerCase()}%';
      query.where(
        inventoryTable.name.lower().like(pattern) |
            inventoryTable.shortDescription.lower().like(pattern),
      );
    }

    query.orderBy([
      OrderingTerm(expression: firstLetterExp, mode: OrderingMode.asc),
    ]);

    final results = await query.map((row) => row.read(firstLetterExp)).get();
    return results.whereType<String>().toList();
  }

  // ---- PURCHASES ----

  Future<int> insertPurchase(PurchaseTableCompanion purchase) async {
    return await transaction(() async {
      final purchaseId = await into(purchaseTable).insert(purchase);
      if (purchase.inventoryId.present &&
          purchase.inventoryId.value != null &&
          purchase.purchaseQty.present &&
          purchase.purchaseQty.value != null) {
        final invId = purchase.inventoryId.value!;
        final qty = purchase.purchaseQty.value!;
        final item = await (select(
          inventoryTable,
        )..where((t) => t.id.equals(invId))).getSingleOrNull();
        if (item != null) {
          final currentStock = item.currentStock ?? 0.0;
          await (update(
            inventoryTable,
          )..where((t) => t.id.equals(invId))).write(
            InventoryTableCompanion(
              currentStock: Value(currentStock + qty),
              modifiedDate: Value(DateTime.now().toIso8601String()),
            ),
          );
        }
      }
      return purchaseId;
    });
  }

  Future<int> updatePurchase(PurchaseTableCompanion purchase) async {
    return await transaction(() async {
      if (purchase.id.present) {
        final targetId = purchase.id.value;
        final oldRecord = await (select(
          purchaseTable,
        )..where((t) => t.id.equals(targetId))).getSingleOrNull();

        if (oldRecord != null) {
          final oldQty = oldRecord.purchaseQty ?? 0.0;
          final oldInvId = oldRecord.inventoryId;

          final newQty = purchase.purchaseQty.present
              ? (purchase.purchaseQty.value ?? oldQty)
              : oldQty;
          final newInvId = purchase.inventoryId.present
              ? (purchase.inventoryId.value ?? oldInvId)
              : oldInvId;

          if (oldInvId == newInvId) {
            final qtyDelta = newQty - oldQty;
            if (newInvId != null && qtyDelta != 0.0) {
              final item = await (select(
                inventoryTable,
              )..where((t) => t.id.equals(newInvId))).getSingleOrNull();
              if (item != null) {
                final currentStock = item.currentStock ?? 0.0;
                await (update(
                  inventoryTable,
                )..where((t) => t.id.equals(newInvId))).write(
                  InventoryTableCompanion(
                    currentStock: Value(currentStock + qtyDelta),
                    modifiedDate: Value(DateTime.now().toIso8601String()),
                  ),
                );
              }
            }
          } else {
            if (oldInvId != null && oldQty != 0.0) {
              final oldItem = await (select(
                inventoryTable,
              )..where((t) => t.id.equals(oldInvId))).getSingleOrNull();
              if (oldItem != null) {
                final currentStock = oldItem.currentStock ?? 0.0;
                await (update(
                  inventoryTable,
                )..where((t) => t.id.equals(oldInvId))).write(
                  InventoryTableCompanion(
                    currentStock: Value(currentStock - oldQty),
                    modifiedDate: Value(DateTime.now().toIso8601String()),
                  ),
                );
              }
            }
            if (newInvId != null && newQty != 0.0) {
              final newItem = await (select(
                inventoryTable,
              )..where((t) => t.id.equals(newInvId))).getSingleOrNull();
              if (newItem != null) {
                final currentStock = newItem.currentStock ?? 0.0;
                await (update(
                  inventoryTable,
                )..where((t) => t.id.equals(newInvId))).write(
                  InventoryTableCompanion(
                    currentStock: Value(currentStock + newQty),
                    modifiedDate: Value(DateTime.now().toIso8601String()),
                  ),
                );
              }
            }
          }
        }
        await update(purchaseTable).replace(purchase);
        return targetId;
      }
      return 0;
    });
  }

  Future<int> deletePurchase(int id) async {
    return await transaction(() async {
      final record = await (select(
        purchaseTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (record != null) {
        final qty = record.purchaseQty ?? 0.0;
        if (record.inventoryId != null && qty != 0.0) {
          final item = await (select(
            inventoryTable,
          )..where((t) => t.id.equals(record.inventoryId!))).getSingleOrNull();
          if (item != null) {
            final currentStock = item.currentStock ?? 0.0;
            await (update(
              inventoryTable,
            )..where((t) => t.id.equals(item.id))).write(
              InventoryTableCompanion(
                currentStock: Value(currentStock - qty),
                modifiedDate: Value(DateTime.now().toIso8601String()),
              ),
            );
          }
        }
      }
      return await (delete(purchaseTable)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> insertPurchaseBatch(
    List<PurchaseTableCompanion> purchases,
  ) async {
    await transaction(() async {
      for (final purchase in purchases) {
        await into(purchaseTable).insert(purchase);
      }
    });
  }

  Future<void> updatePurchaseBatch(
    List<PurchaseTableCompanion> purchases,
  ) async {
    await transaction(() async {
      for (final purchase in purchases) {
        await update(purchaseTable).replace(purchase);
      }
    });
  }

  Future<void> deletePurchaseBatch(List<int> ids) async {
    await transaction(() async {
      for (final id in ids) {
        await (delete(purchaseTable)..where((t) => t.id.equals(id))).go();
      }
    });
  }

  Future<List<PurchaseRecord>> getAllPurchases() async {
    final query = select(purchaseTable);
    return await (query..orderBy([
          (t) => OrderingTerm(
            expression: t.purchaseDateTime,
            mode: OrderingMode.desc,
          ),
        ]))
        .get();
  }

  Future<double> getDailyExpenditureCost(String currentDate) async {
    final totalExp = purchaseTable.purchasePrice.sum();
    final query = selectOnly(purchaseTable)..addColumns([totalExp]);
    query.where(purchaseTable.purchaseDateTime.like('$currentDate%'));
    return await query.map((row) => row.read(totalExp)).getSingle() ?? 0.0;
  }

  Future<double> getMonthlyExpenditureCost(String month) async {
    final totalExp = purchaseTable.purchasePrice.sum();
    final query = selectOnly(purchaseTable)..addColumns([totalExp]);
    query.where(purchaseTable.purchaseDateTime.like('$month%'));
    return await query.map((row) => row.read(totalExp)).getSingle() ?? 0.0;
  }

  Future<List<PurchaseRecord>> getPurchasesBetweenDates({
    required String fromDateTime,
    required String toDateTime,
  }) async {
    final query = select(purchaseTable)
      ..where(
        (t) => t.purchaseDateTime.isBetweenValues(fromDateTime, toDateTime),
      );
    return await (query..orderBy([
          (t) => OrderingTerm(
            expression: t.purchaseDateTime,
            mode: OrderingMode.asc,
          ),
        ]))
        .get();
  }

  Future<double> getExpenditureBetweenDates({
    required String fromDateTime,
    required String toDateTime,
  }) async {
    final totalExp = purchaseTable.purchasePrice.sum();
    final query = selectOnly(purchaseTable)..addColumns([totalExp]);
    query.where(
      purchaseTable.purchaseDateTime.isBetweenValues(fromDateTime, toDateTime),
    );
    return await query.map((row) => row.read(totalExp)).getSingle() ?? 0.0;
  }
}
