part of 'menu_item_picker_bloc.dart';

sealed class MenuItemPickerState extends Equatable {
  const MenuItemPickerState();

  @override
  List<Object?> get props => [];
}

class MenuItemPickerInitialState extends MenuItemPickerState {
  const MenuItemPickerInitialState();
}

class MenuItemPickerLoadingState extends MenuItemPickerState {
  const MenuItemPickerLoadingState();
}

class MenuItemPickerLoadedState extends MenuItemPickerState {
  final MenuCatalogData catalogData;
  final int selectedTabIndex;
  final List<OrderCartItem> cartItems;
  final String searchQuery;
  final String overallOrderRemarks;
  final bool isSubmitting;
  final String? orderSuccessMessage;
  final int? createdOrderId;
  final String? submittedTableName;
  final String? errorMessage;
  final int? editingOrderId;
  final int? loadedTableId;
  final String? loadedTableName;

  const MenuItemPickerLoadedState({
    required this.catalogData,
    this.selectedTabIndex = 0,
    this.cartItems = const [],
    this.searchQuery = '',
    this.overallOrderRemarks = '',
    this.isSubmitting = false,
    this.orderSuccessMessage,
    this.createdOrderId,
    this.submittedTableName,
    this.errorMessage,
    this.editingOrderId,
    this.loadedTableId,
    this.loadedTableName,
  });

  MenuItemPickerLoadedState copyWith({
    MenuCatalogData? catalogData,
    int? selectedTabIndex,
    List<OrderCartItem>? cartItems,
    String? searchQuery,
    String? overallOrderRemarks,
    bool? isSubmitting,
    String? orderSuccessMessage,
    int? createdOrderId,
    String? submittedTableName,
    String? errorMessage,
    int? editingOrderId,
    int? loadedTableId,
    String? loadedTableName,
  }) {
    return MenuItemPickerLoadedState(
      catalogData: catalogData ?? this.catalogData,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      cartItems: cartItems ?? this.cartItems,
      searchQuery: searchQuery ?? this.searchQuery,
      overallOrderRemarks: overallOrderRemarks ?? this.overallOrderRemarks,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      orderSuccessMessage: orderSuccessMessage,
      createdOrderId: createdOrderId ?? this.createdOrderId,
      submittedTableName: submittedTableName ?? this.submittedTableName,
      errorMessage: errorMessage,
      editingOrderId: editingOrderId ?? this.editingOrderId,
      loadedTableId: loadedTableId ?? this.loadedTableId,
      loadedTableName: loadedTableName ?? this.loadedTableName,
    );
  }

  int getItemQuantityInCart(int menuItemId, int? variationId) {
    for (final item in cartItems) {
      if (item.menuItemId == menuItemId && item.variationId == variationId) {
        return item.quantity;
      }
    }
    return 0;
  }

  int get totalCartItemCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalCartAmount {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  @override
  List<Object?> get props => [
    catalogData,
    selectedTabIndex,
    cartItems,
    searchQuery,
    overallOrderRemarks,
    isSubmitting,
    orderSuccessMessage,
    createdOrderId,
    submittedTableName,
    errorMessage,
    editingOrderId,
    loadedTableId,
    loadedTableName,
  ];
}

class MenuItemPickerErrorState extends MenuItemPickerState {
  final String message;

  const MenuItemPickerErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
