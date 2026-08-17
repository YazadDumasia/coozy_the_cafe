// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipes_dao.dart';

// ignore_for_file: type=lint
mixin _$RecipesDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $RecipesTableTable get recipesTable => attachedDatabase.recipesTable;
  RecipesDaoManager get managers => RecipesDaoManager(this);
}

class RecipesDaoManager {
  final _$RecipesDaoMixin _db;
  RecipesDaoManager(this._db);
  $$RecipesTableTableTableManager get recipesTable =>
      $$RecipesTableTableTableManager(_db.attachedDatabase, _db.recipesTable);
}
