part of 'order_management_bloc.dart';

sealed class OrderManagementEvent extends Equatable {
  const OrderManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersEvent extends OrderManagementEvent {
  final bool isRefresh;
  final String? searchQuery;
  final DateTimeRange? dateRange;
  final String? statusFilter;

  const LoadOrdersEvent({
    this.isRefresh = false,
    this.searchQuery,
    this.dateRange,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [isRefresh, searchQuery, dateRange, statusFilter];
}

class LoadMoreOrdersEvent extends OrderManagementEvent {
  const LoadMoreOrdersEvent();
}

class SelectDateRangeEvent extends OrderManagementEvent {
  final DateTimeRange? dateRange;

  const SelectDateRangeEvent(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

class ChangeStatusFilterEvent extends OrderManagementEvent {
  final String status;

  const ChangeStatusFilterEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class LoadOrderDetailsEvent extends OrderManagementEvent {
  final int orderId;

  const LoadOrderDetailsEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderStatusEvent extends OrderManagementEvent {
  final int orderId;
  final String status;

  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}
