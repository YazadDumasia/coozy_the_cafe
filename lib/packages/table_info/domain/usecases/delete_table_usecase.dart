import '../repositories/table_repository.dart';

class DeleteTableUseCase {
  final TableRepository repository;

  DeleteTableUseCase(this.repository);

  Future<bool> call(int tableId) {
    return repository.deleteTable(tableId);
  }
}
