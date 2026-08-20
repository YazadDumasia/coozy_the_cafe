part of 'purchase_list_bloc.dart';

class PurchaseListState extends Equatable {
  final List<PurchaseRecord> purchases;
  final bool hasReachedMax;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final PurchaseSummary? purchaseSummary;

  const PurchaseListState({
    this.purchases = const [],
    this.hasReachedMax = false,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.purchaseSummary,
  });

  PurchaseListState copyWith({
    List<PurchaseRecord>? purchases,
    bool? hasReachedMax,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    PurchaseSummary? purchaseSummary,
  }) {
    return PurchaseListState(
      purchases: purchases ?? this.purchases,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      purchaseSummary: purchaseSummary ?? this.purchaseSummary,
    );
  }

  @override
  List<Object?> get props => [
    purchases,
    hasReachedMax,
    isLoading,
    errorMessage,
    searchQuery,
    purchaseSummary,
  ];
}
