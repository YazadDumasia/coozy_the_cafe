import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

import '../entities/stock_alert.dart';
import '../entities/stock_threshold.dart';
import '../entities/auto_reorder_suggestion.dart';

abstract class InventoryIntelligenceRepository {
  Stream<Either<Failure, List<StockAlert>>> watchActiveAlerts();
  Future<Either<Failure, List<StockAlert>>> getActiveAlerts();
  Stream<Either<Failure, List<StockThreshold>>> watchStockThresholds();
  Future<Either<Failure, List<StockThreshold>>> getStockThresholds();
  Future<Either<Failure, bool>> updateStockThreshold(StockThreshold threshold);
  Future<Either<Failure, bool>> dismissStockAlert(
    int alertId, {
    String? remarks,
  });
  Future<Either<Failure, List<StockAlert>>> scanAndGenerateAlerts();
  Future<Either<Failure, List<AutoReorderSuggestion>>>
  getAutoReorderSuggestions();
  Future<Either<Failure, int>> executeReorder(
    List<AutoReorderSuggestion> suggestions,
  );
}
