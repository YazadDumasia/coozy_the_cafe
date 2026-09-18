import '../../domain/entities/stock_adjustment.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart' as db;

class StockAdjustmentModel extends StockAdjustment {
  const StockAdjustmentModel({
    super.id,
    super.hashId,
    super.inventoryId,
    super.inventoryName,
    super.adjustmentType,
    super.adjustedQty,
    super.previousStock,
    super.newStock,
    super.reason,
    super.createdDate,
  });

  factory StockAdjustmentModel.fromData(db.InventoryStockAdjustment data) {
    return StockAdjustmentModel(
      id: data.id,
      hashId: data.hashId,
      inventoryId: data.inventoryId,
      inventoryName: data.inventoryName,
      adjustmentType: data.adjustmentType,
      adjustedQty: data.adjustedQty,
      previousStock: data.previousStock,
      newStock: data.newStock,
      reason: data.reason,
      createdDate: data.createdDate,
    );
  }
}
