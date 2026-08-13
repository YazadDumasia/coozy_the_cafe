import '../entities/table_info.dart';
import '../repositories/table_repository.dart';

class UpdateTableUseCase {
  final TableRepository repository;

  UpdateTableUseCase(this.repository);

  Future<bool> call(TableInfo table) {
    return repository.updateTable(table);
  }
}
