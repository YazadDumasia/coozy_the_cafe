import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';

import '../../domain/entities/stock_alert.dart';
import '../../domain/entities/stock_threshold.dart';

class StockAlertModel extends StockAlert {
  const StockAlertModel({
    super.id,
    super.hashId,
    required super.inventoryId,
    required super.inventoryName,
    required super.currentStock,
    required super.minThreshold,
    super.purchaseUnit,
    super.severity = AlertSeverity.warning,
    super.status = AlertStatus.active,
    super.createdDate,
    super.resolvedDate,
    super.remarks,
  });

  factory StockAlertModel.fromData(StockAlertData data) {
    return StockAlertModel(
      id: data.id,
      hashId: data.hashId,
      inventoryId: data.inventoryId,
      inventoryName: data.inventoryName,
      currentStock: data.currentStock,
      minThreshold: data.minThreshold,
      purchaseUnit: data.purchaseUnit,
      severity: AlertSeverity.fromString(data.severity),
      status: AlertStatus.fromString(data.status),
      createdDate: data.createdDate,
      resolvedDate: data.resolvedDate,
      remarks: data.remarks,
    );
  }

  StockAlertsTableCompanion toCompanion() {
    return StockAlertsTableCompanion.insert(
      hashId: Value(hashId ?? ''),
      inventoryId: inventoryId,
      inventoryName: inventoryName,
      currentStock: currentStock,
      minThreshold: minThreshold,
      purchaseUnit: Value(purchaseUnit),
      severity: Value(severity.name),
      status: Value(status.name),
      createdDate: Value(createdDate ?? DateTime.now().toIso8601String()),
    );
  }
}

class StockThresholdModel extends StockThreshold {
  const StockThresholdModel({
    super.id,
    super.hashId,
    required super.inventoryId,
    required super.inventoryName,
    super.minThreshold = 5.0,
    super.reorderQuantity = 20.0,
    super.autoReorder = true,
    super.preferredSupplier,
    super.estimatedCost,
    super.updatedDate,
  });

  factory StockThresholdModel.fromData(StockThresholdData data) {
    return StockThresholdModel(
      id: data.id,
      hashId: data.hashId,
      inventoryId: data.inventoryId,
      inventoryName: '',
      minThreshold: data.minThreshold,
      reorderQuantity: data.reorderQuantity,
      autoReorder: data.isAutoReorderEnabled,
      preferredSupplier: data.preferredSupplier,
      estimatedCost: data.preferredUnitCost,
      updatedDate: data.modifiedDate ?? data.createdDate,
    );
  }

  StockThresholdsTableCompanion toCompanion() {
    return StockThresholdsTableCompanion.insert(
      hashId: Value(hashId ?? ''),
      inventoryId: inventoryId,
      minThreshold: Value(minThreshold),
      reorderQuantity: Value(reorderQuantity),
      isAutoReorderEnabled: Value(autoReorder),
      preferredSupplier: Value(preferredSupplier),
      preferredUnitCost: Value(estimatedCost),
      modifiedDate: Value(updatedDate ?? DateTime.now().toIso8601String()),
    );
  }
}
