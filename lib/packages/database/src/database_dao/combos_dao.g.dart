// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combos_dao.dart';

// ignore_for_file: type=lint
mixin _$CombosDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $CombosTableTable get combosTable => attachedDatabase.combosTable;
  $MenuItemsTableTable get menuItemsTable => attachedDatabase.menuItemsTable;
  $MenuItemVariationsTableTable get menuItemVariationsTable =>
      attachedDatabase.menuItemVariationsTable;
  $ComboItemsTableTable get comboItemsTable => attachedDatabase.comboItemsTable;
  CombosDaoManager get managers => CombosDaoManager(this);
}

class CombosDaoManager {
  final _$CombosDaoMixin _db;
  CombosDaoManager(this._db);
  $$CombosTableTableTableManager get combosTable =>
      $$CombosTableTableTableManager(_db.attachedDatabase, _db.combosTable);
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
  $$ComboItemsTableTableTableManager get comboItemsTable =>
      $$ComboItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.comboItemsTable,
      );
}
