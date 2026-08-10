import 'package:equatable/equatable.dart';
import '../../../domain/entities/inventory_item.dart';

class InventoryPickerState extends Equatable {
  final List<InventoryItem> items;
  final bool hasReachedMax;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  const InventoryPickerState({
    this.items = const <InventoryItem>[],
    this.hasReachedMax = false,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  InventoryPickerState copyWith({
    List<InventoryItem>? items,
    bool? hasReachedMax,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return InventoryPickerState(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    items,
    hasReachedMax,
    isLoading,
    errorMessage,
    searchQuery,
  ];
}
