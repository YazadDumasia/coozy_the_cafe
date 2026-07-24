import '../entities/table_info.dart';
import '../repositories/table_repository.dart';

class UpdateTableSortOrdersUseCase {
  final TableRepository repository;

  UpdateTableSortOrdersUseCase(this.repository);

  Future<void> call(List<TableInfo> tables) {
    return repository.updateTableSortOrders(tables);
  }
}
