import '../entities/table_info.dart';
import '../repositories/table_repository.dart';

class AddTableUseCase {
  final TableRepository repository;

  AddTableUseCase(this.repository);

  Future<int> call(TableInfo table) {
    return repository.addTable(table);
  }
}
