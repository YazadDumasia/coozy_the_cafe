part of 'inventory_picker_bloc.dart';

sealed class InventoryPickerEvent extends Equatable {
  const InventoryPickerEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventoryPickerItems extends InventoryPickerEvent {
  final bool isRefresh;
  final String? searchQuery;

  const LoadInventoryPickerItems({this.isRefresh = false, this.searchQuery});

  @override
  List<Object?> get props => [isRefresh, searchQuery];
}
