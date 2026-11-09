import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'stock_alerts_dao.g.dart';

@DriftAccessor(
  tables: [
    InventoryTable,
    StockThresholdsTable,
    StockAlertsTable,
    PurchaseTable,
  ],
)
class StockAlertsDao extends DatabaseAccessor<CoozyDatabase>
    with _$StockAlertsDaoMixin {
  StockAlertsDao(super.db);

  /// Get all stock thresholds joined with inventory item details
  Selectable<TypedResult> selectAllThresholdsWithInventory() {
    return select(stockThresholdsTable).join([
      innerJoin(
        inventoryTable,
        inventoryTable.id.equalsExp(stockThresholdsTable.inventoryId),
      ),
    ]);
  }

  /// Watch all thresholds joined with inventory
  Stream<List<TypedResult>> watchAllThresholdsWithInventory() {
    return selectAllThresholdsWithInventory().watch();
  }

  /// Get all stock thresholds
  Future<List<StockThresholdData>> getAllStockThresholds() {
    return select(stockThresholdsTable).get();
  }

  /// Watch all stock thresholds
  Stream<List<StockThresholdData>> watchStockThresholds() {
    return select(stockThresholdsTable).watch();
  }

  /// Get threshold for a specific inventory item
  Future<StockThresholdData?> getThresholdForInventory(int inventoryId) async {
    final list =
        await (select(stockThresholdsTable)
              ..where((t) => t.inventoryId.equals(inventoryId))
              ..limit(1))
            .get();
    return list.firstOrNull;
  }

  /// Insert or update threshold configuration
  Future<int> upsertThreshold(StockThresholdsTableCompanion companion) {
    return into(stockThresholdsTable).insertOnConflictUpdate(companion);
  }

  /// Watch active alerts
  Stream<List<StockAlertData>> watchActiveAlerts() {
    return (select(stockAlertsTable)
          ..where((a) => a.status.equals('active'))
          ..orderBy([
            (a) => OrderingTerm(expression: a.id, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Get active alerts list
  Future<List<StockAlertData>> getActiveAlerts() {
    return (select(stockAlertsTable)
          ..where((a) => a.status.equals('active'))
          ..orderBy([
            (a) => OrderingTerm(expression: a.id, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Insert alert
  Future<int> insertAlert(StockAlertsTableCompanion companion) {
    return into(stockAlertsTable).insert(companion);
  }

  /// Update alert status (e.g. dismissed or reordered)
  Future<int> dismissAlert(int alertId, {String? remarks}) async {
    return (update(stockAlertsTable)..where((a) => a.id.equals(alertId))).write(
      StockAlertsTableCompanion(
        status: const Value('dismissed'),
        resolvedDate: Value(DateTime.now().toIso8601String()),
        remarks: Value(remarks),
      ),
    );
  }

  /// Mark alert as reordered when a purchase order is created
  Future<int> markAlertReordered(int inventoryId) async {
    return (update(stockAlertsTable)..where(
          (a) => a.inventoryId.equals(inventoryId) & a.status.equals('active'),
        ))
        .write(
          StockAlertsTableCompanion(
            status: const Value('reordered'),
            resolvedDate: Value(DateTime.now().toIso8601String()),
          ),
        );
  }

  /// Scan inventory items and generate stock alerts if current stock <= min threshold
  Future<List<StockAlertData>> scanAndGenerateStockAlerts() async {
    final activeItems = await (select(
      inventoryTable,
    )..where((tbl) => tbl.isEnabled.equals(true))).get();
    final thresholds = await getAllStockThresholds();
    final thresholdMap = {for (var t in thresholds) t.inventoryId: t};

    final generated = <StockAlertData>[];
    final now = DateTime.now().toIso8601String();

    for (final item in activeItems) {
      final currentStock = item.currentStock ?? 0.0;
      final threshold = thresholdMap[item.id];
      final minThreshold = threshold?.minThreshold ?? 5.0;

      if (currentStock <= minThreshold) {
        String severity = 'warning';
        if (currentStock <= 0) {
          severity = 'out_of_stock';
        } else if (currentStock <= (minThreshold * 0.5)) {
          severity = 'critical';
        }

        // Check if there is already an active alert for this inventory item
        final existingList =
            await (select(stockAlertsTable)
                  ..where(
                    (a) =>
                        a.inventoryId.equals(item.id) &
                        a.status.equals('active'),
                  )
                  ..limit(1))
                .get();
        final existing = existingList.firstOrNull;

        if (existing == null) {
          final id = await into(stockAlertsTable).insert(
            StockAlertsTableCompanion.insert(
              inventoryId: item.id,
              inventoryName: item.name ?? 'Item #${item.id}',
              currentStock: currentStock,
              minThreshold: minThreshold,
              purchaseUnit: Value(item.purchaseUnit),
              severity: Value(severity),
              status: const Value('active'),
              createdDate: Value(now),
            ),
          );

          final newAlertList =
              await (select(stockAlertsTable)
                    ..where((a) => a.id.equals(id))
                    ..limit(1))
                  .get();
          if (newAlertList.isNotEmpty) {
            generated.add(newAlertList.first);
          }
        } else {
          // Update current stock and severity on the existing active alert
          await (update(
            stockAlertsTable,
          )..where((a) => a.id.equals(existing.id))).write(
            StockAlertsTableCompanion(
              currentStock: Value(currentStock),
              minThreshold: Value(minThreshold),
              severity: Value(severity),
            ),
          );
          generated.add(
            existing.copyWith(
              currentStock: currentStock,
              minThreshold: minThreshold,
              severity: severity,
            ),
          );
        }
      }
    }

    return generated;
  }
}
