import '../entities/purchase_record.dart';
import '../entities/purchase_summary.dart';

abstract class PurchaseRepository {
  Future<List<PurchaseRecord>> getPurchasesForInventoryItem(int inventoryId);
  Future<List<PurchaseRecord>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<PurchaseRecord>> getAllPurchasesPaged(
    int limit,
    int offset,
    String? search,
  );
  Future<PurchaseSummary> getPurchaseSummary();
  Future<int> addPurchaseRecord(PurchaseRecord record);
  Future<int> updatePurchaseRecord(PurchaseRecord record);
  Future<bool> deletePurchaseRecord(int id);
}
