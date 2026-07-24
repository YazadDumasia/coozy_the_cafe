// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_dao.dart';

// ignore_for_file: type=lint
mixin _$InventoryDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $RolesTableTable get rolesTable => attachedDatabase.rolesTable;
  $UserLoginsTableTable get userLoginsTable => attachedDatabase.userLoginsTable;
  $InventoryTableTable get inventoryTable => attachedDatabase.inventoryTable;
  $PurchaseTableTable get purchaseTable => attachedDatabase.purchaseTable;
  InventoryDaoManager get managers => InventoryDaoManager(this);
}

class InventoryDaoManager {
  final _$InventoryDaoMixin _db;
  InventoryDaoManager(this._db);
  $$RolesTableTableTableManager get rolesTable =>
      $$RolesTableTableTableManager(_db.attachedDatabase, _db.rolesTable);
  $$UserLoginsTableTableTableManager get userLoginsTable =>
      $$UserLoginsTableTableTableManager(
        _db.attachedDatabase,
        _db.userLoginsTable,
      );
  $$InventoryTableTableTableManager get inventoryTable =>
      $$InventoryTableTableTableManager(
        _db.attachedDatabase,
        _db.inventoryTable,
      );
  $$PurchaseTableTableTableManager get purchaseTable =>
      $$PurchaseTableTableTableManager(_db.attachedDatabase, _db.purchaseTable);
}
