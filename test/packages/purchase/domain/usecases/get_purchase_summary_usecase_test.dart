import 'package:flutter_test/flutter_test.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_record.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_summary.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/repositories/purchase_repository.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/usecases/purchase_usecases.dart';

class FakePurchaseRepository implements PurchaseRepository {
  List<PurchaseRecord> records = [];

  @override
  Future<PurchaseSummary> getPurchaseSummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final int daysFromMonday = now.weekday - DateTime.monday;
    final startOfWeek = startOfDay.subtract(Duration(days: daysFromMonday));
    final endOfWeek = startOfWeek
        .add(const Duration(days: 7))
        .subtract(const Duration(milliseconds: 1));

    final startOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextMonthYear = now.month == 12 ? now.year + 1 : now.year;
    final endOfMonth = DateTime(
      nextMonthYear,
      nextMonth,
      1,
    ).subtract(const Duration(milliseconds: 1));

    double dailyTotal = 0.0;
    double weeklyTotal = 0.0;
    double monthlyTotal = 0.0;

    for (var r in records) {
      if (r.purchaseDateTime == null) continue;
      final dt = DateTime.parse(r.purchaseDateTime!).toLocal();
      final price = r.purchasePrice ?? 0.0;

      if ((dt.isAfter(startOfDay) || dt.isAtSameMomentAs(startOfDay)) &&
          (dt.isBefore(endOfDay) || dt.isAtSameMomentAs(endOfDay))) {
        dailyTotal += price;
      }
      if ((dt.isAfter(startOfWeek) || dt.isAtSameMomentAs(startOfWeek)) &&
          (dt.isBefore(endOfWeek) || dt.isAtSameMomentAs(endOfWeek))) {
        weeklyTotal += price;
      }
      if ((dt.isAfter(startOfMonth) || dt.isAtSameMomentAs(startOfMonth)) &&
          (dt.isBefore(endOfMonth) || dt.isAtSameMomentAs(endOfMonth))) {
        monthlyTotal += price;
      }
    }

    return PurchaseSummary(
      dailyTotal: dailyTotal,
      weeklyTotal: weeklyTotal,
      monthlyTotal: monthlyTotal,
    );
  }

  @override
  Future<List<PurchaseRecord>> getPurchasesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return records;
  }

  @override
  Future<List<PurchaseRecord>> getPurchasesForInventoryItem(
    int inventoryId,
  ) async => [];

  @override
  Future<List<PurchaseRecord>> getAllPurchasesPaged(
    int limit,
    int offset,
    String? search,
  ) async => [];

  @override
  Future<int> addPurchaseRecord(PurchaseRecord record) async => 1;

  @override
  Future<int> updatePurchaseRecord(PurchaseRecord record) async => 1;

  @override
  Future<bool> deletePurchaseRecord(int id) async => true;
}

void main() {
  late FakePurchaseRepository fakeRepository;
  late GetPurchaseSummaryUseCase useCase;

  setUp(() {
    fakeRepository = FakePurchaseRepository();
    useCase = GetPurchaseSummaryUseCase(fakeRepository);
  });

  test(
    'should calculate daily, weekly, and monthly totals accurately',
    () async {
      final now = DateTime.now();

      final todayPurchase = PurchaseRecord(
        id: 1,
        purchasePrice: 100.0,
        purchaseDateTime: DateTime(
          now.year,
          now.month,
          now.day,
          10,
          0,
        ).toIso8601String(),
      );

      final pastDate = now.day > 1
          ? DateTime(now.year, now.month, now.day - 1, 12, 0)
          : DateTime(now.year, now.month, now.day + 1, 12, 0);

      final otherDayPurchase = PurchaseRecord(
        id: 2,
        purchasePrice: 50.0,
        purchaseDateTime: pastDate.toIso8601String(),
      );

      fakeRepository.records = [todayPurchase, otherDayPurchase];

      final summary = await useCase();

      expect(summary.dailyTotal, equals(100.0));
      expect(summary.monthlyTotal, equals(150.0));
    },
  );
}
