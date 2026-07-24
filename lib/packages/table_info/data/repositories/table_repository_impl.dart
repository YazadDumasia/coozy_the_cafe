import '../../domain/entities/table_info.dart';
import '../../domain/repositories/table_repository.dart';
import '../datasources/table_local_data_source.dart';
import '../models/table_info_model.dart';

class TableRepositoryImpl implements TableRepository {
  final TableLocalDataSource localDataSource;

  TableRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TableInfo>> getTables() async {
    final models = await localDataSource.getTables();
    return models;
  }

  @override
  Future<int> addTable(TableInfo table) async {
    final model = TableInfoModel.fromEntity(table);
    return await localDataSource.insertTable(model);
  }

  @override
  Future<bool> updateTable(TableInfo table) async {
    final model = TableInfoModel.fromEntity(table);
    return await localDataSource.updateTable(model);
  }

  @override
  Future<bool> deleteTable(int tableId) async {
    return await localDataSource.deleteTable(tableId);
  }

  @override
  Future<void> updateTableSortOrders(List<TableInfo> tables) async {
    final models = tables.map((t) => TableInfoModel.fromEntity(t)).toList();
    await localDataSource.updateSortOrders(models);
  }
}
