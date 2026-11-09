import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

import '../entities/stock_alert.dart';
import '../entities/stock_threshold.dart';
import '../entities/auto_reorder_suggestion.dart';
import '../repositories/inventory_intelligence_repository.dart';

class WatchActiveAlertsUseCase {
  final InventoryIntelligenceRepository repository;
  WatchActiveAlertsUseCase(this.repository);

  Stream<Either<Failure, List<StockAlert>>> call() {
    return repository.watchActiveAlerts();
  }
}

class GetActiveAlertsUseCase {
  final InventoryIntelligenceRepository repository;
  GetActiveAlertsUseCase(this.repository);

  Future<Either<Failure, List<StockAlert>>> call() {
    return repository.getActiveAlerts();
  }
}

class WatchStockThresholdsUseCase {
  final InventoryIntelligenceRepository repository;
  WatchStockThresholdsUseCase(this.repository);

  Stream<Either<Failure, List<StockThreshold>>> call() {
    return repository.watchStockThresholds();
  }
}

class UpdateStockThresholdUseCase {
  final InventoryIntelligenceRepository repository;
  UpdateStockThresholdUseCase(this.repository);

  Future<Either<Failure, bool>> call(StockThreshold threshold) {
    return repository.updateStockThreshold(threshold);
  }
}

class DismissStockAlertUseCase {
  final InventoryIntelligenceRepository repository;
  DismissStockAlertUseCase(this.repository);

  Future<Either<Failure, bool>> call(int alertId, {String? remarks}) {
    return repository.dismissStockAlert(alertId, remarks: remarks);
  }
}

class ScanAndGenerateAlertsUseCase {
  final InventoryIntelligenceRepository repository;
  ScanAndGenerateAlertsUseCase(this.repository);

  Future<Either<Failure, List<StockAlert>>> call() {
    return repository.scanAndGenerateAlerts();
  }
}

class GetAutoReorderSuggestionsUseCase {
  final InventoryIntelligenceRepository repository;
  GetAutoReorderSuggestionsUseCase(this.repository);

  Future<Either<Failure, List<AutoReorderSuggestion>>> call() {
    return repository.getAutoReorderSuggestions();
  }
}

class ExecuteReorderUseCase {
  final InventoryIntelligenceRepository repository;
  ExecuteReorderUseCase(this.repository);

  Future<Either<Failure, int>> call(List<AutoReorderSuggestion> suggestions) {
    return repository.executeReorder(suggestions);
  }
}
