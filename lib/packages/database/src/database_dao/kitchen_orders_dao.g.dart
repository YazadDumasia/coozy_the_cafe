// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_orders_dao.dart';

// ignore_for_file: type=lint
mixin _$KitchenOrdersDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $RolesTableTable get rolesTable => attachedDatabase.rolesTable;
  $UserLoginsTableTable get userLoginsTable => attachedDatabase.userLoginsTable;
  $TableInfoTableTable get tableInfoTable => attachedDatabase.tableInfoTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $ReservationsTableTable get reservationsTable =>
      attachedDatabase.reservationsTable;
  $OrdersTableTable get ordersTable => attachedDatabase.ordersTable;
  $MenuItemsTableTable get menuItemsTable => attachedDatabase.menuItemsTable;
  $MenuItemVariationsTableTable get menuItemVariationsTable =>
      attachedDatabase.menuItemVariationsTable;
  $OrderItemsTableTable get orderItemsTable => attachedDatabase.orderItemsTable;
  KitchenOrdersDaoManager get managers => KitchenOrdersDaoManager(this);
}

class KitchenOrdersDaoManager {
  final _$KitchenOrdersDaoMixin _db;
  KitchenOrdersDaoManager(this._db);
  $$RolesTableTableTableManager get rolesTable =>
      $$RolesTableTableTableManager(_db.attachedDatabase, _db.rolesTable);
  $$UserLoginsTableTableTableManager get userLoginsTable =>
      $$UserLoginsTableTableTableManager(
        _db.attachedDatabase,
        _db.userLoginsTable,
      );
  $$TableInfoTableTableTableManager get tableInfoTable =>
      $$TableInfoTableTableTableManager(
        _db.attachedDatabase,
        _db.tableInfoTable,
      );
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
        _db.attachedDatabase,
        _db.customersTable,
      );
  $$ReservationsTableTableTableManager get reservationsTable =>
      $$ReservationsTableTableTableManager(
        _db.attachedDatabase,
        _db.reservationsTable,
      );
  $$OrdersTableTableTableManager get ordersTable =>
      $$OrdersTableTableTableManager(_db.attachedDatabase, _db.ordersTable);
  $$MenuItemsTableTableTableManager get menuItemsTable =>
      $$MenuItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.menuItemsTable,
      );
  $$MenuItemVariationsTableTableTableManager get menuItemVariationsTable =>
      $$MenuItemVariationsTableTableTableManager(
        _db.attachedDatabase,
        _db.menuItemVariationsTable,
      );
  $$OrderItemsTableTableTableManager get orderItemsTable =>
      $$OrderItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.orderItemsTable,
      );
}
