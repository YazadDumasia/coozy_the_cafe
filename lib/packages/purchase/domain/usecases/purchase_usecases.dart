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
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextMonthYear = now.month == 12 ? now.year + 1 : now.year;
    final endOfMonth = DateTime(
      nextMonthYear,
      nextMonth,
      1,
    ).subtract(const Duration(milliseconds: 1));

    final records = await repository.getPurchasesByDateRange(
      startOfMonth,
      endOfMonth,
    );

    double monthlyTotal = 0;
    double weeklyTotal = 0;
    double dailyTotal = 0;

    final startOfDay = DateTime(now.year, now.month, now.day);

    // Find start of week (Monday)
    int daysFromMonday = now.weekday - DateTime.monday;
    final startOfWeek = startOfDay.subtract(Duration(days: daysFromMonday));

    for (var record in records) {
      if (record.purchaseDateTime == null) continue;
      final dt = DateTime.tryParse(record.purchaseDateTime!);
      if (dt == null) continue;

      final price = record.purchasePrice ?? 0.0;

      monthlyTotal += price;

      if (dt.isAfter(startOfWeek) || dt.isAtSameMomentAs(startOfWeek)) {
        weeklyTotal += price;
      }

      if (dt.isAfter(startOfDay) || dt.isAtSameMomentAs(startOfDay)) {
        dailyTotal += price;
      }
    }

    return PurchaseSummary(
      dailyTotal: dailyTotal,
      weeklyTotal: weeklyTotal,
      monthlyTotal: monthlyTotal,
    );
  }
}
