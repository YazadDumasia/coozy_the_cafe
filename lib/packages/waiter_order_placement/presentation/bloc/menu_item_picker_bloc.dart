import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/menu_catalog_data.dart';
import '../../domain/entities/order_cart_item.dart';
import '../../domain/usecases/get_active_menu_catalog_usecase.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../../domain/usecases/submit_order_usecase.dart';

part 'menu_item_picker_event.dart';
part 'menu_item_picker_state.dart';

class MenuItemPickerBloc
    extends Bloc<MenuItemPickerEvent, MenuItemPickerState> {
  final GetActiveMenuCatalogUseCase getActiveMenuCatalogUseCase;
  final SubmitOrderUseCase submitOrderUseCase;
  final GetOrderDetailsUseCase getOrderDetailsUseCase;

  MenuItemPickerBloc({
    required this.getActiveMenuCatalogUseCase,
    required this.submitOrderUseCase,
    required this.getOrderDetailsUseCase,
  }) : super(const MenuItemPickerInitialState()) {
    on<LoadMenuCatalogEvent>(_onLoadMenuCatalog);
    on<SelectCategoryTabEvent>(_onSelectCategoryTab);
    on<AddItemToCartEvent>(_onAddItemToCart);
    on<RemoveItemFromCartEvent>(_onRemoveItemFromCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<FilterSearchQueryEvent>(_onFilterSearchQuery);
    on<SubmitOrderEvent>(_onSubmitOrder);
  }

  Future<void> _onLoadMenuCatalog(
    LoadMenuCatalogEvent event,
    Emitter<MenuItemPickerState> emit,
  ) async {
    emit(const MenuItemPickerLoadingState());
    final catalogResult = await getActiveMenuCatalogUseCase();

    if (catalogResult.isLeft()) {
      final failureMessage =
          catalogResult.fold((l) => l.message, (_) => 'Failed to load menu catalog');
      emit(MenuItemPickerErrorState(message: failureMessage));
      return;
    }

    final catalogData = catalogResult.getOrElse(() => throw Exception());
    List<OrderCartItem> initialCartItems = const [];
    int? loadedTableId;
    String? loadedTableName;

    if (event.orderId != null) {
      final orderDetailsResult = await getOrderDetailsUseCase(event.orderId!);
      orderDetailsResult.fold(
        (failure) {},
        (details) {
          initialCartItems = details.cartItems;
          loadedTableId = details.tableId;
          loadedTableName = details.tableName;
        },
      );
    }

    emit(
      MenuItemPickerLoadedState(
        catalogData: catalogData,
        selectedTabIndex: 0,
        cartItems: initialCartItems,
        editingOrderId: event.orderId,
        loadedTableId: loadedTableId,
        loadedTableName: loadedTableName,
      ),
    );
  }

  void _onSelectCategoryTab(
    SelectCategoryTabEvent event,
    Emitter<MenuItemPickerState> emit,
  ) {
    if (state is MenuItemPickerLoadedState) {
      final currentState = state as MenuItemPickerLoadedState;
      emit(currentState.copyWith(selectedTabIndex: event.index));
    }
  }

  void _onAddItemToCart(
    AddItemToCartEvent event,
    Emitter<MenuItemPickerState> emit,
  ) {
    if (state is MenuItemPickerLoadedState) {
      final currentState = state as MenuItemPickerLoadedState;
      final currentCart = List<OrderCartItem>.from(currentState.cartItems);

      final price = event.variation?.sellingPrice ?? event.item.sellingPrice ?? 0.0;
      final varName = event.variation?.name;
      final varId = event.variation?.id;

      final existingIndex = currentCart.indexWhere(
        (ci) => ci.menuItemId == event.item.id && ci.variationId == varId,
      );

      if (existingIndex >= 0) {
        final existingItem = currentCart[existingIndex];
        currentCart[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        currentCart.add(
          OrderCartItem(
            menuItemId: event.item.id,
            name: event.item.name,
            variationId: varId,
            variationName: varName,
            price: price,
            quantity: 1,
            subcategoryId: event.item.subcategoryId,
            subcategoryName: event.subcategoryName,
            categoryId: event.categoryId ?? event.item.categoryId,
          ),
        );
      }

      emit(currentState.copyWith(cartItems: currentCart));
    }
  }

  void _onRemoveItemFromCart(
    RemoveItemFromCartEvent event,
    Emitter<MenuItemPickerState> emit,
  ) {
    if (state is MenuItemPickerLoadedState) {
      final currentState = state as MenuItemPickerLoadedState;
      final currentCart = List<OrderCartItem>.from(currentState.cartItems);

      final varId = event.variation?.id;
      final existingIndex = currentCart.indexWhere(
        (ci) => ci.menuItemId == event.item.id && ci.variationId == varId,
      );

      if (existingIndex >= 0) {
        final existingItem = currentCart[existingIndex];
        if (existingItem.quantity > 1) {
          currentCart[existingIndex] = existingItem.copyWith(
            quantity: existingItem.quantity - 1,
          );
        } else {
          currentCart.removeAt(existingIndex);
        }
        emit(currentState.copyWith(cartItems: currentCart));
      }
    }
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<MenuItemPickerState> emit,
  ) {
    if (state is MenuItemPickerLoadedState) {
      final currentState = state as MenuItemPickerLoadedState;
      final currentCart = List<OrderCartItem>.from(currentState.cartItems);

      final existingIndex = currentCart.indexWhere(
        (ci) =>
            ci.menuItemId == event.cartItem.menuItemId &&
            ci.variationId == event.cartItem.variationId,
      );

      if (existingIndex >= 0) {
        if (event.newQuantity <= 0) {
          currentCart.removeAt(existingIndex);
        } else {
          currentCart[existingIndex] = currentCart[existingIndex].copyWith(
            quantity: event.newQuantity,
          );
        }
        emit(currentState.copyWith(cartItems: currentCart));
      }
    }
  }

  void _onFilterSearchQuery(
    FilterSearchQueryEvent event,
    Emitter<MenuItemPickerState> emit,
  ) {
    if (state is MenuItemPickerLoadedState) {
      final currentState = state as MenuItemPickerLoadedState;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onSubmitOrder(
    SubmitOrderEvent event,
    Emitter<MenuItemPickerState> emit,
  ) async {
    if (state is MenuItemPickerLoadedState) {
      final currentState = state as MenuItemPickerLoadedState;

      if (currentState.cartItems.isEmpty) {
        emit(currentState.copyWith(errorMessage: 'Cart is empty. Please add items to place order.'));
        return;
      }

      emit(currentState.copyWith(isSubmitting: true));

      final targetOrderId = event.orderId ?? currentState.editingOrderId;
      final result = await submitOrderUseCase(
        tableId: event.tableId,
        tableName: event.tableName,
        cartItems: currentState.cartItems,
        orderId: targetOrderId,
      );

      result.fold(
        (failure) => emit(
          currentState.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
          ),
        ),
        (orderId) => emit(
          currentState.copyWith(
            isSubmitting: false,
            orderSuccessMessage: 'order_placed_successfully_for_table_msg',
            createdOrderId: orderId,
            submittedTableName: event.tableName,
            cartItems: const [],
          ),
        ),
      );
    }
  }
}
