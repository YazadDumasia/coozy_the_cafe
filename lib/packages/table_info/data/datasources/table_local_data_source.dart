import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../models/table_info_model.dart';

abstract class TableLocalDataSource {
  Future<List<TableInfoModel>> getTables();
  Future<int> insertTable(TableInfoModel table);
  Future<bool> updateTable(TableInfoModel table);
  Future<bool> deleteTable(int id);
  Future<void> updateSortOrders(List<TableInfoModel> tables);
}

class TableLocalDataSourceImpl implements TableLocalDataSource {
  final CoozyDatabase database;

  TableLocalDataSourceImpl({required this.database});

  CustomersDao get _customersDao => database.customersDao;

  @override
  Future<List<TableInfoModel>> getTables() async {
    final results = await _customersDao.getTableInfos();
    return (results ?? [])
        .map((data) => TableInfoModel.fromTableInfoData(data))
        .toList();
  }

  @override
  Future<int> insertTable(TableInfoModel table) async {
    final result = await _customersDao.addTableInfo(table.toCompanion());
    return result ?? 0;
  }

  @override
  Future<bool> updateTable(TableInfoModel table) async {
    final result = await _customersDao.updateTableInfo(table.toCompanion());
    return result != null && result > 0;
  }

  @override
  Future<bool> deleteTable(int id) async {
    final model = await _customersDao.getTableInfo(id);
    if (model != null) {
      final result = await _customersDao.deleteTableInfo(model);
      return result != null && result > 0;
    }
    return false;
  }

  @override
  Future<void> updateSortOrders(List<TableInfoModel> tables) async {
    await database.batch((batch) {
      for (final table in tables) {
        batch.update(
          database.tableInfoTable,
          table.toCompanion(),
          where: (t) => t.id.equals(table.id!),
        );
      }
    });
  }
}
