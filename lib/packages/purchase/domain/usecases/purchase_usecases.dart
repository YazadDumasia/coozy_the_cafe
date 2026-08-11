import '../entities/purchase_record.dart';
import '../entities/purchase_summary.dart';
import '../repositories/purchase_repository.dart';

class GetPurchasesUseCase {
  final PurchaseRepository repository;
  GetPurchasesUseCase(this.repository);

  Future<List<PurchaseRecord>> call(int inventoryId) async {
    return await repository.getPurchasesForInventoryItem(inventoryId);
  }
}

class GetAllPurchasesPagedUseCase {
  final PurchaseRepository repository;
  GetAllPurchasesPagedUseCase(this.repository);

  Future<List<PurchaseRecord>> call(
    int limit,
    int offset,
    String? search,
  ) async {
    return await repository.getAllPurchasesPaged(limit, offset, search);
  }
}

class AddPurchaseRecordUseCase {
  final PurchaseRepository repository;
  AddPurchaseRecordUseCase(this.repository);

  Future<int> call(PurchaseRecord record) async {
    return await repository.addPurchaseRecord(record);
  }
}

class UpdatePurchaseRecordUseCase {
  final PurchaseRepository repository;
  UpdatePurchaseRecordUseCase(this.repository);

  Future<int> call(PurchaseRecord record) async {
    return await repository.updatePurchaseRecord(record);
  }
}

class DeletePurchaseRecordUseCase {
  final PurchaseRepository repository;
  DeletePurchaseRecordUseCase(this.repository);

  Future<bool> call(int id) async {
    return await repository.deletePurchaseRecord(id);
  }
}

class GetPurchaseSummaryUseCase {
  final PurchaseRepository repository;
  GetPurchaseSummaryUseCase(this.repository);

  Future<PurchaseSummary> call() async {
    return await repository.getPurchaseSummary();
  }
}
