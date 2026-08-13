import '../entities/table_info.dart';
import '../repositories/table_repository.dart';

class GetTablesUseCase {
  final TableRepository repository;

  GetTablesUseCase(this.repository);

  Future<List<TableInfo>> call() {
    return repository.getTables();
  }
}
