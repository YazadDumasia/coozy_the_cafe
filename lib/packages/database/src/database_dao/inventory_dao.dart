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
      return await into(purchaseTable).insert(purchase);
    });
  }

  Future<int> updatePurchase(PurchaseTableCompanion purchase) async {
    return await transaction(() async {
      await update(purchaseTable).replace(purchase);
      return 1;
    });
  }

  Future<int> deletePurchase(int id) async {
    return await transaction(() async {
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
