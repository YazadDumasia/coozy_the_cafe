import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

import '../../domain/entities/stock_alert.dart';
import '../../domain/entities/stock_threshold.dart';
import '../../domain/entities/auto_reorder_suggestion.dart';
import '../../domain/usecases/inventory_intelligence_usecases.dart';

part 'stock_alerts_state.dart';

class StockAlertsCubit extends Cubit<StockAlertsState> {
  final WatchActiveAlertsUseCase watchActiveAlertsUseCase;
  final GetActiveAlertsUseCase getActiveAlertsUseCase;
  final WatchStockThresholdsUseCase watchStockThresholdsUseCase;
  final UpdateStockThresholdUseCase updateStockThresholdUseCase;
  final DismissStockAlertUseCase dismissStockAlertUseCase;
  final ScanAndGenerateAlertsUseCase scanAndGenerateAlertsUseCase;
  final GetAutoReorderSuggestionsUseCase getAutoReorderSuggestionsUseCase;
  final ExecuteReorderUseCase executeReorderUseCase;

  StreamSubscription? _alertsSubscription;
  StreamSubscription? _thresholdsSubscription;

  StockAlertsCubit({
    required this.watchActiveAlertsUseCase,
    required this.getActiveAlertsUseCase,
    required this.watchStockThresholdsUseCase,
    required this.updateStockThresholdUseCase,
    required this.dismissStockAlertUseCase,
    required this.scanAndGenerateAlertsUseCase,
    required this.getAutoReorderSuggestionsUseCase,
    required this.executeReorderUseCase,
  }) : super(const StockAlertsInitial()) {
    loadStockIntelligence();
  }

  void loadStockIntelligence() async {
    PlatformUtils.debugLog(StockAlertsCubit, 'loadStockIntelligence: starting');
    emit(const StockAlertsLoading());

    // 1. Initial scan to detect low stock against thresholds
    await scanAndGenerateAlertsUseCase();

    // 2. Fetch reorder suggestions
    final suggestionsResult = await getAutoReorderSuggestionsUseCase();
    final suggestions = suggestionsResult.fold(
      (failure) => <AutoReorderSuggestion>[],
      (data) => data,
    );

    // 3. Listen to reactive stream of active alerts
    await _alertsSubscription?.cancel();
    _alertsSubscription = watchActiveAlertsUseCase().listen((either) {
      either.fold(
        (failure) {
          PlatformUtils.debugLog(
            StockAlertsCubit,
            'watchActiveAlerts failure: ${failure.message}',
          );
          emit(StockAlertsError(failure.message));
        },
        (alerts) {
          if (state is StockAlertsLoaded) {
            final current = state as StockAlertsLoaded;
            emit(current.copyWith(alerts: alerts));
          } else {
            emit(
              StockAlertsLoaded(
                alerts: alerts,
                thresholds: const [],
                reorderSuggestions: suggestions,
              ),
            );
          }
        },
      );
    });

    // 4. Listen to thresholds stream
    await _thresholdsSubscription?.cancel();
    _thresholdsSubscription = watchStockThresholdsUseCase().listen((either) {
      either.fold((failure) => null, (thresholds) {
        if (state is StockAlertsLoaded) {
          final current = state as StockAlertsLoaded;
          emit(current.copyWith(thresholds: thresholds));
        }
      });
    });
  }

  Future<void> scanDeficits() async {
    PlatformUtils.debugLog(
      StockAlertsCubit,
      'scanDeficits: manually triggered',
    );
    final result = await scanAndGenerateAlertsUseCase();
    result.fold((failure) => emit(StockAlertsError(failure.message)), (
      _,
    ) async {
      await refreshSuggestions();
    });
  }

  void applyFilter({String? query, AlertSeverity? severity}) {
    if (state is StockAlertsLoaded) {
      final current = state as StockAlertsLoaded;
      emit(
        current.copyWith(
          searchQuery: query ?? current.searchQuery,
          filterSeverity: severity,
          clearFilterSeverity: severity == null,
        ),
      );
    }
  }

  Future<void> dismissAlert(int alertId) async {
    PlatformUtils.debugLog(StockAlertsCubit, 'dismissAlert: alertId=$alertId');
    final result = await dismissStockAlertUseCase(alertId);
    result.fold((failure) => emit(StockAlertsError(failure.message)), (_) {
      emit(const StockAlertsActionSuccess('Alert dismissed'));
    });
  }

  Future<void> updateThreshold({
    required int inventoryId,
    required double minThreshold,
    required double suggestedReorderQuantity,
    bool autoReorderEnabled = true,
  }) async {
    PlatformUtils.debugLog(
      StockAlertsCubit,
      'updateThreshold: inventoryId=$inventoryId, min=$minThreshold, reorder=$suggestedReorderQuantity',
    );
    final threshold = StockThreshold(
      inventoryId: inventoryId,
      inventoryName: '',
      minThreshold: minThreshold,
      reorderQuantity: suggestedReorderQuantity,
      autoReorder: autoReorderEnabled,
    );
    final result = await updateStockThresholdUseCase(threshold);
    result.fold((failure) => emit(StockAlertsError(failure.message)), (
      _,
    ) async {
      emit(const StockAlertsActionSuccess('Threshold updated successfully'));
      await scanAndGenerateAlertsUseCase();
      await refreshSuggestions();
    });
  }

  Future<List<AutoReorderSuggestion>> fetchSuggestions() async {
    final result = await getAutoReorderSuggestionsUseCase();
    return result.fold((failure) => <AutoReorderSuggestion>[], (data) => data);
  }

  Future<void> refreshSuggestions() async {
    final suggestions = await fetchSuggestions();
    if (state is StockAlertsLoaded) {
      final current = state as StockAlertsLoaded;
      emit(current.copyWith(reorderSuggestions: suggestions));
    }
  }

  Future<void> reorderBatch(List<AutoReorderSuggestion> suggestions) async {
    PlatformUtils.debugLog(
      StockAlertsCubit,
      'reorderBatch: ordering ${suggestions.length} items',
    );
    final result = await executeReorderUseCase(suggestions);
    result.fold((failure) => emit(StockAlertsError(failure.message)), (
      count,
    ) async {
      emit(
        StockAlertsActionSuccess(
          'Generated $count purchase orders successfully!',
        ),
      );
      await refreshSuggestions();
      await scanAndGenerateAlertsUseCase();
    });
  }

  @override
  Future<void> close() {
    _alertsSubscription?.cancel();
    _thresholdsSubscription?.cancel();
    return super.close();
  }
}
