import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/order_management_entity.dart';
import '../../domain/usecases/get_paginated_orders_usecase.dart';
import '../../domain/usecases/get_order_info_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';

part 'order_management_event.dart';
part 'order_management_state.dart';

class OrderManagementBloc
    extends Bloc<OrderManagementEvent, OrderManagementState> {
  final GetPaginatedOrdersUseCase getPaginatedOrdersUseCase;
  final GetOrderInfoUseCase getOrderInfoUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  static const int pageSize = 15;

  OrderManagementBloc({
    required this.getPaginatedOrdersUseCase,
    required this.getOrderInfoUseCase,
    required this.updateOrderStatusUseCase,
  }) : super(const OrderManagementInitialState()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<LoadMoreOrdersEvent>(_onLoadMoreOrders);
    on<SelectDateRangeEvent>(_onSelectDateRange);
    on<ChangeStatusFilterEvent>(_onChangeStatusFilter);
    on<LoadOrderDetailsEvent>(_onLoadOrderDetails);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
  }

  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrderManagementState> emit,
  ) async {
    final currentState = state;
    String query = event.searchQuery ?? '';
    DateTimeRange? range = event.dateRange;
    String status = event.statusFilter ?? 'all';

    if (!event.isRefresh && currentState is OrderManagementLoadedState) {
      query = event.searchQuery ?? currentState.searchQuery;
      range = event.dateRange ?? currentState.dateRange;
      status = event.statusFilter ?? currentState.selectedStatus;
    }

    if (currentState is! OrderManagementLoadedState || event.isRefresh) {
      emit(const OrderManagementLoadingState());
    }

    final result = await getPaginatedOrdersUseCase(
      GetPaginatedOrdersParams(
        limit: pageSize,
        pageNo: 1,
        startDate: range?.start,
        endDate: range?.end,
        searchQuery: query,
        status: status,
      ),
    );

    result.fold(
      (failure) => emit(OrderManagementErrorState(failure.message)),
      (paginated) {
        final hasReachedMax = paginated.orders.length >= paginated.totalCount;
        emit(
          OrderManagementLoadedState(
            orders: paginated.orders,
            totalCount: paginated.totalCount,
            currentPage: 1,
            hasReachedMax: hasReachedMax,
            searchQuery: query,
            dateRange: range,
            selectedStatus: status,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreOrders(
    LoadMoreOrdersEvent event,
    Emitter<OrderManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrderManagementLoadedState) return;
    if (currentState.hasReachedMax || currentState.isFetchingMore) return;

    emit(currentState.copyWith(isFetchingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await getPaginatedOrdersUseCase(
      GetPaginatedOrdersParams(
        limit: pageSize,
        pageNo: nextPage,
        startDate: currentState.dateRange?.start,
        endDate: currentState.dateRange?.end,
        searchQuery: currentState.searchQuery,
        status: currentState.selectedStatus,
      ),
    );

    result.fold(
      (failure) => emit(
        currentState.copyWith(
          isFetchingMore: false,
          errorMessage: failure.message,
        ),
      ),
      (paginated) {
        final updatedOrders = [
          ...currentState.orders,
          ...paginated.orders,
        ];
        final hasReachedMax = updatedOrders.length >= paginated.totalCount;

        emit(
          currentState.copyWith(
            orders: updatedOrders,
            totalCount: paginated.totalCount,
            currentPage: nextPage,
            hasReachedMax: hasReachedMax,
            isFetchingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onSelectDateRange(
    SelectDateRangeEvent event,
    Emitter<OrderManagementState> emit,
  ) async {
    add(
      LoadOrdersEvent(
        isRefresh: true,
        dateRange: event.dateRange,
      ),
    );
  }

  Future<void> _onChangeStatusFilter(
    ChangeStatusFilterEvent event,
    Emitter<OrderManagementState> emit,
  ) async {
    add(
      LoadOrdersEvent(
        isRefresh: true,
        statusFilter: event.status,
      ),
    );
  }

  Future<void> _onLoadOrderDetails(
    LoadOrderDetailsEvent event,
    Emitter<OrderManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderManagementLoadedState) {
      emit(currentState.copyWith(isLoadingDetails: true));
      final result = await getOrderInfoUseCase(event.orderId);
      result.fold(
        (failure) => emit(
          currentState.copyWith(
            isLoadingDetails: false,
            errorMessage: failure.message,
          ),
        ),
        (details) => emit(
          currentState.copyWith(
            isLoadingDetails: false,
            selectedOrderDetails: details,
          ),
        ),
      );
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderManagementState> emit,
  ) async {
    final result = await updateOrderStatusUseCase(
      UpdateOrderStatusParams(
        orderId: event.orderId,
        status: event.status,
      ),
    );

    result.fold(
      (failure) {
        if (state is OrderManagementLoadedState) {
          emit(
            (state as OrderManagementLoadedState).copyWith(
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) {
        add(const LoadOrdersEvent(isRefresh: true));
      },
    );
  }
}
