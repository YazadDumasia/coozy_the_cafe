import '../entities/table_info.dart';

abstract class TableRepository {
  Future<List<TableInfo>> getTables();
  Future<int> addTable(TableInfo table);
  Future<bool> updateTable(TableInfo table);
  Future<bool> deleteTable(int tableId);
  Future<void> updateTableSortOrders(List<TableInfo> tables);
}
