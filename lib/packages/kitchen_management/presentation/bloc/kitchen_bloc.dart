import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/kitchen_aggregated_item_entity.dart';
import '../../domain/entities/kitchen_order_entity.dart';
import '../../domain/usecases/get_active_kitchen_orders_usecase.dart';
import '../../domain/usecases/get_aggregated_pending_items_usecase.dart';
import '../../domain/usecases/update_all_order_items_status_usecase.dart';
import '../../domain/usecases/update_order_item_status_usecase.dart';
import '../../domain/usecases/watch_active_kitchen_orders_usecase.dart';

part 'kitchen_event.dart';
part 'kitchen_state.dart';

class KitchenBloc extends Bloc<KitchenEvent, KitchenState> {
  final GetActiveKitchenOrdersUseCase getActiveKitchenOrdersUseCase;
  final WatchActiveKitchenOrdersUseCase watchActiveKitchenOrdersUseCase;
  final UpdateOrderItemStatusUseCase updateOrderItemStatusUseCase;
  final UpdateAllOrderItemsStatusUseCase updateAllOrderItemsStatusUseCase;
  final GetAggregatedPendingItemsUseCase getAggregatedPendingItemsUseCase;

  StreamSubscription<List<KitchenOrderEntity>>? _ordersSubscription;

  KitchenBloc({
    required this.getActiveKitchenOrdersUseCase,
    required this.watchActiveKitchenOrdersUseCase,
    required this.updateOrderItemStatusUseCase,
    required this.updateAllOrderItemsStatusUseCase,
    required this.getAggregatedPendingItemsUseCase,
  }) : super(const KitchenInitialState()) {
    on<LoadKitchenOrdersEvent>(_onLoadKitchenOrders);
    on<ToggleViewModeEvent>(_onToggleViewMode);
    on<UpdateItemStatusEvent>(_onUpdateItemStatus);
    on<BumpAllOrderItemsEvent>(_onBumpAllOrderItems);
    on<FilterStatusChangedEvent>(_onFilterStatusChanged);
    on<_KitchenOrdersUpdatedEvent>(_onOrdersUpdated);

    _subscribeToLiveOrders();
  }

  void _subscribeToLiveOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = watchActiveKitchenOrdersUseCase().listen(
      (orders) {
        add(_KitchenOrdersUpdatedEvent(orders));
      },
      onError: (error) {
        add(const LoadKitchenOrdersEvent());
      },
    );
  }

  Future<void> _onOrdersUpdated(
    _KitchenOrdersUpdatedEvent event,
    Emitter<KitchenState> emit,
  ) async {
    final currentViewMode = state is KitchenLoadedState
        ? (state as KitchenLoadedState).viewMode
        : KitchenViewMode.tickets;
    final currentFilter = state is KitchenLoadedState
        ? (state as KitchenLoadedState).statusFilter
        : 'all';

    final aggregatedResult = await getAggregatedPendingItemsUseCase();

    aggregatedResult.fold(
      (failure) => emit(KitchenErrorState(failure.message)),
      (aggregatedItems) {
        emit(
          KitchenLoadedState(
            orders: event.orders,
            aggregatedItems: aggregatedItems,
            viewMode: currentViewMode,
            statusFilter: currentFilter,
          ),
        );
      },
    );
  }

  Future<void> _onLoadKitchenOrders(
    LoadKitchenOrdersEvent event,
    Emitter<KitchenState> emit,
  ) async {
    final currentViewMode = state is KitchenLoadedState
        ? (state as KitchenLoadedState).viewMode
        : KitchenViewMode.tickets;
    final currentFilter = state is KitchenLoadedState
        ? (state as KitchenLoadedState).statusFilter
        : 'all';

    emit(const KitchenLoadingState());

    final ordersResult = await getActiveKitchenOrdersUseCase();
    final aggregatedResult = await getAggregatedPendingItemsUseCase();

    ordersResult.fold((failure) => emit(KitchenErrorState(failure.message)), (
      orders,
    ) {
      aggregatedResult.fold(
        (failure) => emit(KitchenErrorState(failure.message)),
        (aggregatedItems) {
          emit(
            KitchenLoadedState(
              orders: orders,
              aggregatedItems: aggregatedItems,
              viewMode: currentViewMode,
              statusFilter: currentFilter,
            ),
          );
        },
      );
    });
  }

  void _onToggleViewMode(
    ToggleViewModeEvent event,
    Emitter<KitchenState> emit,
  ) {
    if (state is KitchenLoadedState) {
      final currentState = state as KitchenLoadedState;
      emit(currentState.copyWith(viewMode: event.viewMode));
    }
  }

  void _onFilterStatusChanged(
    FilterStatusChangedEvent event,
    Emitter<KitchenState> emit,
  ) {
    if (state is KitchenLoadedState) {
      final currentState = state as KitchenLoadedState;
      emit(currentState.copyWith(statusFilter: event.statusFilter));
    }
  }

  Future<void> _onUpdateItemStatus(
    UpdateItemStatusEvent event,
    Emitter<KitchenState> emit,
  ) async {
    final result = await updateOrderItemStatusUseCase(
      orderItemId: event.orderItemId,
      status: event.newStatus,
    );

    result.fold(
      (failure) => emit(KitchenErrorState(failure.message)),
      (_) => add(const LoadKitchenOrdersEvent()),
    );
  }

  Future<void> _onBumpAllOrderItems(
    BumpAllOrderItemsEvent event,
    Emitter<KitchenState> emit,
  ) async {
    final result = await updateAllOrderItemsStatusUseCase(
      orderId: event.orderId,
      status: event.newStatus,
    );

    result.fold(
      (failure) => emit(KitchenErrorState(failure.message)),
      (_) => add(const LoadKitchenOrdersEvent()),
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
