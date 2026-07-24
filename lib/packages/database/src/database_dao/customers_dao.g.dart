// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomersDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $RolesTableTable get rolesTable => attachedDatabase.rolesTable;
  $UserLoginsTableTable get userLoginsTable => attachedDatabase.userLoginsTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $TableInfoTableTable get tableInfoTable => attachedDatabase.tableInfoTable;
  CustomersDaoManager get managers => CustomersDaoManager(this);
}

class CustomersDaoManager {
  final _$CustomersDaoMixin _db;
  CustomersDaoManager(this._db);
  $$RolesTableTableTableManager get rolesTable =>
      $$RolesTableTableTableManager(_db.attachedDatabase, _db.rolesTable);
  $$UserLoginsTableTableTableManager get userLoginsTable =>
      $$UserLoginsTableTableTableManager(
        _db.attachedDatabase,
        _db.userLoginsTable,
      );
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
        _db.attachedDatabase,
        _db.customersTable,
      );
  $$TableInfoTableTableTableManager get tableInfoTable =>
      $$TableInfoTableTableTableManager(
        _db.attachedDatabase,
        _db.tableInfoTable,
      );
}
