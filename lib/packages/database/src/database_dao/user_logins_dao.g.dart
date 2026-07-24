// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_logins_dao.dart';

// ignore_for_file: type=lint
mixin _$UserLoginsDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $RolesTableTable get rolesTable => attachedDatabase.rolesTable;
  $UserLoginsTableTable get userLoginsTable => attachedDatabase.userLoginsTable;
  $PermissionsTableTable get permissionsTable =>
      attachedDatabase.permissionsTable;
  $RolePermissionsTableTable get rolePermissionsTable =>
      attachedDatabase.rolePermissionsTable;
  UserLoginsDaoManager get managers => UserLoginsDaoManager(this);
}

class UserLoginsDaoManager {
  final _$UserLoginsDaoMixin _db;
  UserLoginsDaoManager(this._db);
  $$RolesTableTableTableManager get rolesTable =>
      $$RolesTableTableTableManager(_db.attachedDatabase, _db.rolesTable);
  $$UserLoginsTableTableTableManager get userLoginsTable =>
      $$UserLoginsTableTableTableManager(
        _db.attachedDatabase,
        _db.userLoginsTable,
      );
  $$PermissionsTableTableTableManager get permissionsTable =>
      $$PermissionsTableTableTableManager(
        _db.attachedDatabase,
        _db.permissionsTable,
      );
  $$RolePermissionsTableTableTableManager get rolePermissionsTable =>
      $$RolePermissionsTableTableTableManager(
        _db.attachedDatabase,
        _db.rolePermissionsTable,
      );
}
