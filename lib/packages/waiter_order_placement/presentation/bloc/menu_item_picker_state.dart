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
  final bool isSubmitting;
  final String? orderSuccessMessage;
  final String? errorMessage;

  const MenuItemPickerLoadedState({
    required this.catalogData,
    this.selectedTabIndex = 0,
    this.cartItems = const [],
    this.searchQuery = '',
    this.isSubmitting = false,
    this.orderSuccessMessage,
    this.errorMessage,
  });

  MenuItemPickerLoadedState copyWith({
    MenuCatalogData? catalogData,
    int? selectedTabIndex,
    List<OrderCartItem>? cartItems,
    String? searchQuery,
    bool? isSubmitting,
    String? orderSuccessMessage,
    String? errorMessage,
  }) {
    return MenuItemPickerLoadedState(
      catalogData: catalogData ?? this.catalogData,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      cartItems: cartItems ?? this.cartItems,
      searchQuery: searchQuery ?? this.searchQuery,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      orderSuccessMessage: orderSuccessMessage,
      errorMessage: errorMessage,
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
        isSubmitting,
        orderSuccessMessage,
        errorMessage,
      ];
}

class MenuItemPickerErrorState extends MenuItemPickerState {
  final String message;

  const MenuItemPickerErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
