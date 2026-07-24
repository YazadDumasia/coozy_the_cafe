// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservations_dao.dart';

// ignore_for_file: type=lint
mixin _$ReservationsDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $RolesTableTable get rolesTable => attachedDatabase.rolesTable;
  $UserLoginsTableTable get userLoginsTable => attachedDatabase.userLoginsTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $TableInfoTableTable get tableInfoTable => attachedDatabase.tableInfoTable;
  $ReservationsTableTable get reservationsTable =>
      attachedDatabase.reservationsTable;
  ReservationsDaoManager get managers => ReservationsDaoManager(this);
}

class ReservationsDaoManager {
  final _$ReservationsDaoMixin _db;
  ReservationsDaoManager(this._db);
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
  $$ReservationsTableTableTableManager get reservationsTable =>
      $$ReservationsTableTableTableManager(
        _db.attachedDatabase,
        _db.reservationsTable,
      );
}
