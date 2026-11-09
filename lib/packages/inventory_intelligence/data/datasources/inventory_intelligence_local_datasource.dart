import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'package:coozy_the_cafe/packages/database/src/database_dao/stock_alerts_dao.dart';

import '../../domain/entities/stock_alert.dart';
import '../../domain/entities/stock_threshold.dart';
import '../../domain/entities/auto_reorder_suggestion.dart';
import '../models/stock_alert_model.dart';

abstract class InventoryIntelligenceLocalDataSource {
  Stream<List<StockAlert>> watchActiveAlerts();
  Future<List<StockAlert>> getActiveAlerts();
  Stream<List<StockThreshold>> watchStockThresholds();
  Future<List<StockThreshold>> getStockThresholds();
  Future<bool> updateStockThreshold(StockThresholdModel threshold);
  Future<bool> dismissStockAlert(int alertId, {String? remarks});
  Future<List<StockAlert>> scanAndGenerateAlerts();
  Future<List<AutoReorderSuggestion>> getAutoReorderSuggestions();
  Future<int> executeReorder(List<AutoReorderSuggestion> suggestions);
}

class InventoryIntelligenceLocalDataSourceImpl
    implements InventoryIntelligenceLocalDataSource {
  final StockAlertsDao stockAlertsDao;
  final CoozyDatabase database;

  InventoryIntelligenceLocalDataSourceImpl({
    required this.stockAlertsDao,
    required this.database,
  });

  @override
  Stream<List<StockAlert>> watchActiveAlerts() {
    return stockAlertsDao.watchActiveAlerts().map(
      (rows) => rows.map((row) => StockAlertModel.fromData(row)).toList(),
    );
  }

  @override
  Future<List<StockAlert>> getActiveAlerts() async {
    final rows = await stockAlertsDao.getActiveAlerts();
    return rows.map((row) => StockAlertModel.fromData(row)).toList();
  }

  @override
  Stream<List<StockThreshold>> watchStockThresholds() {
    return stockAlertsDao.watchStockThresholds().map(
      (rows) => rows.map((row) => StockThresholdModel.fromData(row)).toList(),
    );
  }

  @override
  Future<List<StockThreshold>> getStockThresholds() async {
    final rows = await stockAlertsDao.getAllStockThresholds();
    return rows.map((row) => StockThresholdModel.fromData(row)).toList();
  }

  @override
  Future<bool> updateStockThreshold(StockThresholdModel threshold) async {
    final companion = StockThresholdsTableCompanion(
      inventoryId: Value(threshold.inventoryId),
      minThreshold: Value(threshold.minThreshold),
      reorderQuantity: Value(threshold.reorderQuantity),
      isAutoReorderEnabled: Value(threshold.autoReorder),
      preferredSupplier: Value(threshold.preferredSupplier),
      preferredUnitCost: Value(threshold.estimatedCost),
      modifiedDate: Value(DateTime.now().toIso8601String()),
    );
    await stockAlertsDao.upsertThreshold(companion);
    return true;
  }

  @override
  Future<bool> dismissStockAlert(int alertId, {String? remarks}) async {
    final rowsUpdated = await stockAlertsDao.dismissAlert(
      alertId,
      remarks: remarks,
    );
    return rowsUpdated > 0;
  }

  @override
  Future<List<StockAlert>> scanAndGenerateAlerts() async {
    final rows = await stockAlertsDao.scanAndGenerateStockAlerts();
    return rows.map((row) => StockAlertModel.fromData(row)).toList();
  }

  @override
  Future<List<AutoReorderSuggestion>> getAutoReorderSuggestions() async {
    final alerts = await getActiveAlerts();
    final thresholds = await getStockThresholds();
    final thresholdMap = {for (var t in thresholds) t.inventoryId: t};

    final suggestions = <AutoReorderSuggestion>[];
    for (final alert in alerts) {
      final t = thresholdMap[alert.inventoryId];
      if (t != null && !t.autoReorder) continue;

      final reorderQty =
          t?.reorderQuantity ?? (alert.deficit > 0 ? alert.deficit : 10.0);

      suggestions.add(
        AutoReorderSuggestion(
          inventoryId: alert.inventoryId,
          inventoryName: alert.inventoryName,
          purchaseUnit: alert.purchaseUnit,
          currentStock: alert.currentStock,
          minThreshold: alert.minThreshold,
          suggestedReorderQty: reorderQty,
          preferredSupplier: t?.preferredSupplier,
          estimatedUnitCost: t?.estimatedCost,
        ),
      );
    }
    return suggestions;
  }

  @override
  Future<int> executeReorder(List<AutoReorderSuggestion> suggestions) async {
    var createdCount = 0;
    final now = DateTime.now().toIso8601String();

    await database.transaction(() async {
      for (final s in suggestions) {
        await database
            .into(database.purchaseTable)
            .insert(
              PurchaseTableCompanion.insert(
                inventoryId: Value(s.inventoryId),
                name: Value(s.inventoryName),
                purchaseUnit: Value(s.purchaseUnit ?? ''),
                purchaseQty: Value(s.suggestedReorderQty),
                purchasePrice: Value(s.estimatedUnitCost ?? 0.0),
                purchaseDateTime: Value(now),
                createdDate: Value(now),
              ),
            );
        await stockAlertsDao.markAlertReordered(s.inventoryId);
        createdCount++;
      }
    });

    return createdCount;
  }
}
