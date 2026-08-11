import 'package:coozy_the_cafe/packages/database/coozy_database.dart' as db;
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_summary.dart';
import '../models/purchase_record_model.dart';

abstract class PurchaseLocalDataSource {
  Future<List<PurchaseRecordModel>> getPurchasesForInventoryItem(
    int inventoryId,
  );
  Future<List<PurchaseRecordModel>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<PurchaseRecordModel>> getAllPurchasesPaged(
    int limit,
    int offset,
    String? search,
  );
  Future<PurchaseSummary> getPurchaseSummary();
  Future<int> insertPurchaseRecord(PurchaseRecordModel record);
  Future<int> updatePurchaseRecord(PurchaseRecordModel record);
  Future<int> deletePurchaseRecord(int id);
}

class PurchaseLocalDataSourceImpl implements PurchaseLocalDataSource {
  final db.CoozyDatabase database;

  PurchaseLocalDataSourceImpl({required this.database});

  db.InventoryDao get _inventoryDao => database.inventoryDao;

  @override
  Future<List<PurchaseRecordModel>> getPurchasesForInventoryItem(
    int inventoryId,
  ) async {
    final results = await _inventoryDao.getAllPurchases();
    return results
        .where((r) => r.inventoryId == inventoryId)
        .map((e) => PurchaseRecordModel.fromData(e))
        .toList();
  }

  @override
  Future<List<PurchaseRecordModel>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final results = await _inventoryDao.getPurchasesBetweenDates(
      fromDateTime: start.toIso8601String(),
      toDateTime: end.toIso8601String(),
    );
    return results.map((r) => PurchaseRecordModel.fromData(r)).toList();
  }

  @override
  Future<List<PurchaseRecordModel>> getAllPurchasesPaged(
    int limit,
    int offset,
    String? search,
  ) async {
    final results = await _inventoryDao.getAllPurchases();
    var filtered = results;
    if (search != null && search.isNotEmpty) {
      final term = search.toLowerCase();
      filtered = filtered
          .where((r) => r.name?.toLowerCase().contains(term) ?? false)
          .toList();
    }
    final paged = filtered.skip(offset).take(limit).toList();

    final List<PurchaseRecordModel> result = [];
    for (final record in paged) {
      double currentStock = 0.0;
      if (record.inventoryId != null) {
        final item = await _inventoryDao.getInventoryById(record.inventoryId!);
        currentStock = item?.currentStock ?? 0.0;
      }
      result.add(
        PurchaseRecordModel.fromData(record, currentStock: currentStock),
      );
    }

    return result;
  }

  @override
  Future<PurchaseSummary> getPurchaseSummary() async {
    final now = DateTime.now();

    final String currentDateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final String currentMonthStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final startOfDay = DateTime(now.year, now.month, now.day);
    final int daysFromMonday = now.weekday - DateTime.monday;
    final startOfWeek = startOfDay.subtract(Duration(days: daysFromMonday));
    final endOfWeek = startOfWeek
        .add(const Duration(days: 7))
        .subtract(const Duration(milliseconds: 1));

    final dailyTotal = await _inventoryDao.getDailyExpenditureCost(
      currentDateStr,
    );
    final weeklyTotal = await _inventoryDao.getExpenditureBetweenDates(
      fromDateTime: startOfWeek.toIso8601String(),
      toDateTime: endOfWeek.toIso8601String(),
    );
    final monthlyTotal = await _inventoryDao.getMonthlyExpenditureCost(
      currentMonthStr,
    );

    return PurchaseSummary(
      dailyTotal: dailyTotal,
      weeklyTotal: weeklyTotal,
      monthlyTotal: monthlyTotal,
    );
  }

  @override
  Future<int> insertPurchaseRecord(PurchaseRecordModel record) async {
    return await _inventoryDao.insertPurchase(record.toCompanion());
  }

  @override
  Future<int> updatePurchaseRecord(PurchaseRecordModel record) async {
    return await _inventoryDao.updatePurchase(record.toCompanion());
  }

  @override
  Future<int> deletePurchaseRecord(int id) async {
    return await _inventoryDao.deletePurchase(id);
  }
}
