import '../entities/table_entity.dart';
import '../repositories/tables_repository.dart';

class WatchTablesUseCase {
  final TablesRepository repository;

  const WatchTablesUseCase(this.repository);

  Stream<List<TableEntity>> call() {
    return repository.watchTablesWithStatus();
  }
}
