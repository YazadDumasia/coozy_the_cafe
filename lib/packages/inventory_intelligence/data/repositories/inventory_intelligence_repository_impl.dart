import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

import '../../domain/entities/stock_alert.dart';
import '../../domain/entities/stock_threshold.dart';
import '../../domain/entities/auto_reorder_suggestion.dart';
import '../../domain/repositories/inventory_intelligence_repository.dart';
import '../datasources/inventory_intelligence_local_datasource.dart';
import '../models/stock_alert_model.dart';

class InventoryIntelligenceRepositoryImpl
    implements InventoryIntelligenceRepository {
  final InventoryIntelligenceLocalDataSource localDataSource;

  InventoryIntelligenceRepositoryImpl({required this.localDataSource});

  @override
  Stream<Either<Failure, List<StockAlert>>> watchActiveAlerts() {
    try {
      return localDataSource.watchActiveAlerts().map(
        (models) => Right<Failure, List<StockAlert>>(models),
      );
    } catch (e) {
      return Stream.value(Left(DatabaseFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<StockAlert>>> getActiveAlerts() async {
    try {
      final models = await localDataSource.getActiveAlerts();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<StockThreshold>>> watchStockThresholds() {
    try {
      return localDataSource.watchStockThresholds().map(
        (models) => Right<Failure, List<StockThreshold>>(models),
      );
    } catch (e) {
      return Stream.value(Left(DatabaseFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<StockThreshold>>> getStockThresholds() async {
    try {
      final models = await localDataSource.getStockThresholds();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateStockThreshold(
    StockThreshold threshold,
  ) async {
    try {
      final model = StockThresholdModel(
        id: threshold.id,
        hashId: threshold.hashId,
        inventoryId: threshold.inventoryId,
        inventoryName: threshold.inventoryName,
        minThreshold: threshold.minThreshold,
        reorderQuantity: threshold.reorderQuantity,
        autoReorder: threshold.autoReorder,
        preferredSupplier: threshold.preferredSupplier,
        estimatedCost: threshold.estimatedCost,
        updatedDate: threshold.updatedDate,
      );
      final success = await localDataSource.updateStockThreshold(model);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> dismissStockAlert(
    int alertId, {
    String? remarks,
  }) async {
    try {
      final success = await localDataSource.dismissStockAlert(
        alertId,
        remarks: remarks,
      );
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockAlert>>> scanAndGenerateAlerts() async {
    try {
      final models = await localDataSource.scanAndGenerateAlerts();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AutoReorderSuggestion>>>
  getAutoReorderSuggestions() async {
    try {
      final suggestions = await localDataSource.getAutoReorderSuggestions();
      return Right(suggestions);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> executeReorder(
    List<AutoReorderSuggestion> suggestions,
  ) async {
    try {
      final count = await localDataSource.executeReorder(suggestions);
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
