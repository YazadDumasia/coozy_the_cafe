part of 'menu_item_picker_bloc.dart';

sealed class MenuItemPickerEvent extends Equatable {
  const MenuItemPickerEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuCatalogEvent extends MenuItemPickerEvent {
  const LoadMenuCatalogEvent();
}

class SelectCategoryTabEvent extends MenuItemPickerEvent {
  final int index;
  const SelectCategoryTabEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class AddItemToCartEvent extends MenuItemPickerEvent {
  final MenuItem item;
  final MenuItemVariation? variation;
  final String? subcategoryName;
  final int? categoryId;

  const AddItemToCartEvent({
    required this.item,
    this.variation,
    this.subcategoryName,
    this.categoryId,
  });

  @override
  List<Object?> get props => [item, variation, subcategoryName, categoryId];
}

class RemoveItemFromCartEvent extends MenuItemPickerEvent {
  final MenuItem item;
  final MenuItemVariation? variation;

  const RemoveItemFromCartEvent({
    required this.item,
    this.variation,
  });

  @override
  List<Object?> get props => [item, variation];
}

class UpdateCartItemQuantityEvent extends MenuItemPickerEvent {
  final OrderCartItem cartItem;
  final int newQuantity;

  const UpdateCartItemQuantityEvent({
    required this.cartItem,
    required this.newQuantity,
  });

  @override
  List<Object?> get props => [cartItem, newQuantity];
}

class FilterSearchQueryEvent extends MenuItemPickerEvent {
  final String query;
  const FilterSearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SubmitOrderEvent extends MenuItemPickerEvent {
  final int tableId;
  final String tableName;

  const SubmitOrderEvent({
    required this.tableId,
    required this.tableName,
  });

  @override
  List<Object?> get props => [tableId, tableName];
}
