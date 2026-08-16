import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/tables_repository.dart';
import '../datasources/table_picker_dao.dart';

class TablesRepositoryImpl implements TablesRepository {
  final TablePickerDao tablePickerDao;

  const TablesRepositoryImpl({required this.tablePickerDao});

  @override
  Stream<List<TableEntity>> watchTablesWithStatus() {
    return tablePickerDao.watchTablesWithStatus();
  }
}
