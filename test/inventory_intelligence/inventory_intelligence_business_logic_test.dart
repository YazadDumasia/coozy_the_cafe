import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/entities/stock_alert.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/entities/stock_threshold.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/entities/auto_reorder_suggestion.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/repositories/inventory_intelligence_repository.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/usecases/inventory_intelligence_usecases.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/presentation/cubit/stock_alerts_cubit.dart';

class MockInventoryIntelligenceRepository
    implements InventoryIntelligenceRepository {
  List<StockAlert> alerts = [];
  List<StockThreshold> thresholds = [];
  List<AutoReorderSuggestion> suggestions = [];

  @override
  Stream<Either<Failure, List<StockAlert>>> watchActiveAlerts() {
    return Stream.value(Right(alerts));
  }

  @override
  Future<Either<Failure, List<StockAlert>>> getActiveAlerts() async {
    return Right(alerts);
  }

  @override
  Stream<Either<Failure, List<StockThreshold>>> watchStockThresholds() {
    return Stream.value(Right(thresholds));
  }

  @override
  Future<Either<Failure, List<StockThreshold>>> getStockThresholds() async {
    return Right(thresholds);
  }

  @override
  Future<Either<Failure, bool>> updateStockThreshold(
    StockThreshold threshold,
  ) async {
    final idx = thresholds.indexWhere(
      (t) => t.inventoryId == threshold.inventoryId,
    );
    if (idx >= 0) {
      thresholds[idx] = threshold;
    } else {
      thresholds.add(threshold);
    }
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> dismissStockAlert(
    int alertId, {
    String? remarks,
  }) async {
    alerts.removeWhere((a) => a.id == alertId);
    return const Right(true);
  }

  @override
  Future<Either<Failure, List<StockAlert>>> scanAndGenerateAlerts() async {
    return Right(alerts);
  }

  @override
  Future<Either<Failure, List<AutoReorderSuggestion>>>
  getAutoReorderSuggestions() async {
    return Right(suggestions);
  }

  @override
  Future<Either<Failure, int>> executeReorder(
    List<AutoReorderSuggestion> suggestions,
  ) async {
    return Right(suggestions.length);
  }
}

void main() {
  late MockInventoryIntelligenceRepository repository;

  setUp(() {
    repository = MockInventoryIntelligenceRepository();
  });

  group('Stock Alert & Threshold Entity Tests', () {
    test('StockAlert calculates deficit correctly', () {
      const alert = StockAlert(
        id: 1,
        inventoryId: 10,
        inventoryName: 'Whole Milk',
        currentStock: 2.0,
        minThreshold: 10.0,
        purchaseUnit: 'Liters',
      );

      expect(alert.deficit, 8.0);
    });

    test('StockAlert deficit clamp returns 0.0 when stock is greater than threshold', () {
      const alert = StockAlert(
        id: 2,
        inventoryId: 11,
        inventoryName: 'Coffee Beans',
        currentStock: 15.0,
        minThreshold: 5.0,
      );

      expect(alert.deficit, 0.0);
    });

    test('AlertSeverity parses correct enum from string', () {
      expect(AlertSeverity.fromString('critical'), AlertSeverity.critical);
      expect(
        AlertSeverity.fromString('out_of_stock'),
        AlertSeverity.outOfStock,
      );
      expect(AlertSeverity.fromString('warning'), AlertSeverity.warning);
      expect(AlertSeverity.fromString('unknown'), AlertSeverity.warning);
    });

    test(
      'AutoReorderSuggestion calculates total estimated cost accurately',
      () {
        const suggestion = AutoReorderSuggestion(
          inventoryId: 10,
          inventoryName: 'Whole Milk',
          currentStock: 2.0,
          minThreshold: 10.0,
          suggestedReorderQty: 25.0,
          estimatedUnitCost: 2.50,
        );

        expect(suggestion.estimatedTotalCost, 62.50);
      },
    );
  });

  group('Inventory Intelligence Domain Use Cases', () {
    test('ScanAndGenerateAlertsUseCase returns active stock alerts', () async {
      repository.alerts = [
        const StockAlert(
          id: 1,
          inventoryId: 101,
          inventoryName: 'Espresso Roast',
          currentStock: 1.0,
          minThreshold: 5.0,
          severity: AlertSeverity.critical,
        ),
      ];

      final useCase = ScanAndGenerateAlertsUseCase(repository);
      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (alerts) {
          expect(alerts.length, 1);
          expect(alerts.first.inventoryName, 'Espresso Roast');
          expect(alerts.first.severity, AlertSeverity.critical);
        },
      );
    });

    test('DismissStockAlertUseCase updates and removes alert', () async {
      repository.alerts = [
        const StockAlert(
          id: 5,
          inventoryId: 102,
          inventoryName: 'Sugar Syrup',
          currentStock: 0.5,
          minThreshold: 3.0,
        ),
      ];

      final useCase = DismissStockAlertUseCase(repository);
      final result = await useCase(5, remarks: 'Supplier contacted manually');

      expect(result.isRight(), isTrue);
      expect(repository.alerts.isEmpty, isTrue);
    });

    test(
      'UpdateStockThresholdUseCase stores updated threshold config',
      () async {
        final useCase = UpdateStockThresholdUseCase(repository);
        const newThreshold = StockThreshold(
          inventoryId: 200,
          inventoryName: 'Oat Milk',
          minThreshold: 8.0,
          reorderQuantity: 30.0,
          autoReorder: true,
        );

        final result = await useCase(newThreshold);
        expect(result.isRight(), isTrue);
        expect(repository.thresholds.length, 1);
        expect(repository.thresholds.first.minThreshold, 8.0);
        expect(repository.thresholds.first.reorderQuantity, 30.0);
      },
    );

    test('ExecuteReorderUseCase generates purchase orders count', () async {
      final useCase = ExecuteReorderUseCase(repository);
      final suggestions = [
        const AutoReorderSuggestion(
          inventoryId: 1,
          inventoryName: 'Green Tea',
          currentStock: 0.0,
          minThreshold: 10.0,
          suggestedReorderQty: 20.0,
        ),
        const AutoReorderSuggestion(
          inventoryId: 2,
          inventoryName: 'Chai Spice',
          currentStock: 1.0,
          minThreshold: 5.0,
          suggestedReorderQty: 10.0,
        ),
      ];

      final result = await useCase(suggestions);
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Failed reorder'), (count) => expect(count, 2));
    });
  });

  group('StockAlertsLoaded Filtering State Tests', () {
    const alert1 = StockAlert(
      id: 1,
      inventoryId: 10,
      inventoryName: 'Whole Milk',
      currentStock: 0.0,
      minThreshold: 10.0,
      severity: AlertSeverity.outOfStock,
    );
    const alert2 = StockAlert(
      id: 2,
      inventoryId: 20,
      inventoryName: 'Espresso Beans',
      currentStock: 2.0,
      minThreshold: 10.0,
      severity: AlertSeverity.critical,
    );
    const alert3 = StockAlert(
      id: 3,
      inventoryId: 30,
      inventoryName: 'Almond Syrup',
      currentStock: 4.0,
      minThreshold: 5.0,
      severity: AlertSeverity.warning,
    );

    test('filteredAlerts returns all alerts when filterSeverity is null', () {
      final state = StockAlertsLoaded(
        alerts: const [alert1, alert2, alert3],
        thresholds: const [],
        reorderSuggestions: const [],
        filterSeverity: null,
      );

      expect(state.filteredAlerts.length, 3);
    });

    test('filteredAlerts filters correctly by AlertSeverity', () {
      final state = StockAlertsLoaded(
        alerts: const [alert1, alert2, alert3],
        thresholds: const [],
        reorderSuggestions: const [],
        filterSeverity: AlertSeverity.outOfStock,
      );

      expect(state.filteredAlerts.length, 1);
      expect(state.filteredAlerts.first.inventoryName, 'Whole Milk');
    });

    test('copyWith clearFilterSeverity clears filter back to null (All)', () {
      final state = StockAlertsLoaded(
        alerts: const [alert1, alert2, alert3],
        thresholds: const [],
        reorderSuggestions: const [],
        filterSeverity: AlertSeverity.critical,
      );

      expect(state.filteredAlerts.length, 1);

      final clearedState = state.copyWith(clearFilterSeverity: true);
      expect(clearedState.filterSeverity, isNull);
      expect(clearedState.filteredAlerts.length, 3);
    });
  });
}
