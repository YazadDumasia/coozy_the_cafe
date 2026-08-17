// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_dao.dart';

// ignore_for_file: type=lint
mixin _$CategoriesDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $SubcategoriesTableTable get subcategoriesTable =>
      attachedDatabase.subcategoriesTable;
  CategoriesDaoManager get managers => CategoriesDaoManager(this);
}

class CategoriesDaoManager {
  final _$CategoriesDaoMixin _db;
  CategoriesDaoManager(this._db);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.categoriesTable,
      );
  $$SubcategoriesTableTableTableManager get subcategoriesTable =>
      $$SubcategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.subcategoriesTable,
      );
}
