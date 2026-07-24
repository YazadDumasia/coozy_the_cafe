import '../../domain/entities/purchase_record.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_local_data_source.dart';
import '../models/purchase_record_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseLocalDataSource localDataSource;

  PurchaseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<PurchaseRecord>> getPurchasesForInventoryItem(
    int inventoryId,
  ) async {
    final records = await localDataSource.getPurchasesForInventoryItem(
      inventoryId,
    );
    return records;
  }

  @override
  Future<List<PurchaseRecord>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await localDataSource.getPurchasesByDateRange(start, end);
  }

  @override
  Future<List<PurchaseRecord>> getAllPurchasesPaged(
    int limit,
    int offset,
    String? search,
  ) async {
    return await localDataSource.getAllPurchasesPaged(limit, offset, search);
  }

  @override
  Future<int> addPurchaseRecord(PurchaseRecord record) async {
    final model = PurchaseRecordModel.fromEntity(record);
    return await localDataSource.insertPurchaseRecord(model);
  }

  @override
  Future<int> updatePurchaseRecord(PurchaseRecord record) async {
    final model = PurchaseRecordModel.fromEntity(record);
    return await localDataSource.updatePurchaseRecord(model);
  }

  @override
  Future<bool> deletePurchaseRecord(int id) async {
    final rowsDeleted = await localDataSource.deletePurchaseRecord(id);
    return rowsDeleted > 0;
  }
}
