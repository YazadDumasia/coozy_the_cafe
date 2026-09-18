// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenditure_dao.dart';

// ignore_for_file: type=lint
mixin _$ExpenditureDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $ExpenditureCategoriesTableTable get expenditureCategoriesTable =>
      attachedDatabase.expenditureCategoriesTable;
  $ExpendituresTableTable get expendituresTable =>
      attachedDatabase.expendituresTable;
  ExpenditureDaoManager get managers => ExpenditureDaoManager(this);
}

class ExpenditureDaoManager {
  final _$ExpenditureDaoMixin _db;
  ExpenditureDaoManager(this._db);
  $$ExpenditureCategoriesTableTableTableManager
  get expenditureCategoriesTable =>
      $$ExpenditureCategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.expenditureCategoriesTable,
      );
  $$ExpendituresTableTableTableManager get expendituresTable =>
      $$ExpendituresTableTableTableManager(
        _db.attachedDatabase,
        _db.expendituresTable,
      );
}
