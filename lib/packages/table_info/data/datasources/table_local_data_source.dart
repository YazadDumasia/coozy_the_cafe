import 'package:drift/drift.dart' hide TableInfo;
import 'package:coozy_the_cafe/packages/database/src/database.dart';
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

  @override
  Future<List<TableInfoModel>> getTables() async {
    final query = database.select(database.tableInfoTable)
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.sortOrderIndex, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return results
        .map((data) => TableInfoModel.fromTableInfoData(data))
        .toList();
  }

  @override
  Future<int> insertTable(TableInfoModel table) async {
    return await database
        .into(database.tableInfoTable)
        .insert(table.toCompanion());
  }

  @override
  Future<bool> updateTable(TableInfoModel table) async {
    return await database
        .update(database.tableInfoTable)
        .replace(table.toCompanion());
  }

  @override
  Future<bool> deleteTable(int id) async {
    final deleted = await (database.delete(
      database.tableInfoTable,
    )..where((t) => t.id.equals(id))).go();
    return deleted > 0;
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
