part of 'stock_alerts_cubit.dart';

sealed class StockAlertsState extends Equatable {
  const StockAlertsState();

  @override
  List<Object?> get props => [];
}

class StockAlertsInitial extends StockAlertsState {
  const StockAlertsInitial();
}

class StockAlertsLoading extends StockAlertsState {
  const StockAlertsLoading();
}

class StockAlertsActionSuccess extends StockAlertsState {
  final String message;
  const StockAlertsActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StockAlertsError extends StockAlertsState {
  final String errorMessage;
  const StockAlertsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class StockAlertsLoaded extends StockAlertsState {
  final List<StockAlert> alerts;
  final List<StockThreshold> thresholds;
  final List<AutoReorderSuggestion> reorderSuggestions;
  final AlertSeverity? filterSeverity;
  final String searchQuery;

  const StockAlertsLoaded({
    required this.alerts,
    required this.thresholds,
    required this.reorderSuggestions,
    this.filterSeverity,
    this.searchQuery = '',
  });

  List<StockAlert> get filteredAlerts {
    return alerts.where((a) {
      final matchesSeverity =
          filterSeverity == null || a.severity == filterSeverity;

      final matchesQuery =
          searchQuery.isEmpty ||
          a.inventoryName.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesSeverity && matchesQuery;
    }).toList();
  }

  int get criticalCount => alerts
      .where(
        (a) =>
            a.severity == AlertSeverity.critical ||
            a.severity == AlertSeverity.outOfStock,
      )
      .length;

  int get warningCount =>
      alerts.where((a) => a.severity == AlertSeverity.warning).length;

  double get totalSuggestedReorderCost => reorderSuggestions.fold<double>(
    0.0,
    (sum, s) => sum + s.estimatedTotalCost,
  );

  StockAlertsLoaded copyWith({
    List<StockAlert>? alerts,
    List<StockThreshold>? thresholds,
    List<AutoReorderSuggestion>? reorderSuggestions,
    AlertSeverity? filterSeverity,
    bool clearFilterSeverity = false,
    String? searchQuery,
  }) {
    return StockAlertsLoaded(
      alerts: alerts ?? this.alerts,
      thresholds: thresholds ?? this.thresholds,
      reorderSuggestions: reorderSuggestions ?? this.reorderSuggestions,
      filterSeverity: clearFilterSeverity
          ? null
          : (filterSeverity ?? this.filterSeverity),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    alerts,
    thresholds,
    reorderSuggestions,
    filterSeverity,
    searchQuery,
  ];
}
