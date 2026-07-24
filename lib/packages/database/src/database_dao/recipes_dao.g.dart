// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipes_dao.dart';

// ignore_for_file: type=lint
mixin _$RecipesDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $RolesTableTable get rolesTable => attachedDatabase.rolesTable;
  $UserLoginsTableTable get userLoginsTable => attachedDatabase.userLoginsTable;
  $RecipesTableTable get recipesTable => attachedDatabase.recipesTable;
  RecipesDaoManager get managers => RecipesDaoManager(this);
}

class RecipesDaoManager {
  final _$RecipesDaoMixin _db;
  RecipesDaoManager(this._db);
  $$RolesTableTableTableManager get rolesTable =>
      $$RolesTableTableTableManager(_db.attachedDatabase, _db.rolesTable);
  $$UserLoginsTableTableTableManager get userLoginsTable =>
      $$UserLoginsTableTableTableManager(
        _db.attachedDatabase,
        _db.userLoginsTable,
      );
  $$RecipesTableTableTableManager get recipesTable =>
      $$RecipesTableTableTableManager(_db.attachedDatabase, _db.recipesTable);
}
