// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_dao.dart';

// ignore_for_file: type=lint
mixin _$InventoryDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $InventoryTableTable get inventoryTable => attachedDatabase.inventoryTable;
  $PurchaseTableTable get purchaseTable => attachedDatabase.purchaseTable;
  $InventoryStockAdjustmentsTableTable get inventoryStockAdjustmentsTable =>
      attachedDatabase.inventoryStockAdjustmentsTable;
  InventoryDaoManager get managers => InventoryDaoManager(this);
}

class InventoryDaoManager {
  final _$InventoryDaoMixin _db;
  InventoryDaoManager(this._db);
  $$InventoryTableTableTableManager get inventoryTable =>
      $$InventoryTableTableTableManager(
        _db.attachedDatabase,
        _db.inventoryTable,
      );
  $$PurchaseTableTableTableManager get purchaseTable =>
      $$PurchaseTableTableTableManager(_db.attachedDatabase, _db.purchaseTable);
  $$InventoryStockAdjustmentsTableTableTableManager
  get inventoryStockAdjustmentsTable =>
      $$InventoryStockAdjustmentsTableTableTableManager(
        _db.attachedDatabase,
        _db.inventoryStockAdjustmentsTable,
      );
}
