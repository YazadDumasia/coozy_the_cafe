// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_alerts_dao.dart';

// ignore_for_file: type=lint
mixin _$StockAlertsDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $InventoryTableTable get inventoryTable => attachedDatabase.inventoryTable;
  $StockThresholdsTableTable get stockThresholdsTable =>
      attachedDatabase.stockThresholdsTable;
  $StockAlertsTableTable get stockAlertsTable =>
      attachedDatabase.stockAlertsTable;
  $PurchaseTableTable get purchaseTable => attachedDatabase.purchaseTable;
  StockAlertsDaoManager get managers => StockAlertsDaoManager(this);
}

class StockAlertsDaoManager {
  final _$StockAlertsDaoMixin _db;
  StockAlertsDaoManager(this._db);
  $$InventoryTableTableTableManager get inventoryTable =>
      $$InventoryTableTableTableManager(
        _db.attachedDatabase,
        _db.inventoryTable,
      );
  $$StockThresholdsTableTableTableManager get stockThresholdsTable =>
      $$StockThresholdsTableTableTableManager(
        _db.attachedDatabase,
        _db.stockThresholdsTable,
      );
  $$StockAlertsTableTableTableManager get stockAlertsTable =>
      $$StockAlertsTableTableTableManager(
        _db.attachedDatabase,
        _db.stockAlertsTable,
      );
  $$PurchaseTableTableTableManager get purchaseTable =>
      $$PurchaseTableTableTableManager(_db.attachedDatabase, _db.purchaseTable);
}
