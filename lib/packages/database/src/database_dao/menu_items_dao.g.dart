// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_items_dao.dart';

// ignore_for_file: type=lint
mixin _$MenuItemsDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $RolesTableTable get rolesTable => attachedDatabase.rolesTable;
  $UserLoginsTableTable get userLoginsTable => attachedDatabase.userLoginsTable;
  $MenuItemsTableTable get menuItemsTable => attachedDatabase.menuItemsTable;
  $MenuItemVariationsTableTable get menuItemVariationsTable =>
      attachedDatabase.menuItemVariationsTable;
  $MenuItemReviewsTableTable get menuItemReviewsTable =>
      attachedDatabase.menuItemReviewsTable;
  MenuItemsDaoManager get managers => MenuItemsDaoManager(this);
}

class MenuItemsDaoManager {
  final _$MenuItemsDaoMixin _db;
  MenuItemsDaoManager(this._db);
  $$RolesTableTableTableManager get rolesTable =>
      $$RolesTableTableTableManager(_db.attachedDatabase, _db.rolesTable);
  $$UserLoginsTableTableTableManager get userLoginsTable =>
      $$UserLoginsTableTableTableManager(
        _db.attachedDatabase,
        _db.userLoginsTable,
      );
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
  $$MenuItemReviewsTableTableTableManager get menuItemReviewsTable =>
      $$MenuItemReviewsTableTableTableManager(
        _db.attachedDatabase,
        _db.menuItemReviewsTable,
      );
}
