import '../entities/table_entity.dart';

abstract class TablesRepository {
  Stream<List<TableEntity>> watchTablesWithStatus();
}
