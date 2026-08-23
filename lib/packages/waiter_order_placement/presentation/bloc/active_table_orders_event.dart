part of 'active_table_orders_bloc.dart';

sealed class ActiveTableOrdersEvent extends Equatable {
  const ActiveTableOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveTableOrdersEvent extends ActiveTableOrdersEvent {
  const LoadActiveTableOrdersEvent();
}

class DeleteTableOrderEvent extends ActiveTableOrdersEvent {
  final int orderId;

  const DeleteTableOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class _ActiveTableOrdersUpdatedEvent extends ActiveTableOrdersEvent {
  final List<ActiveTableOrder> orders;
  final String? error;

  const _ActiveTableOrdersUpdatedEvent(this.orders, {this.error});

  @override
  List<Object?> get props => [orders, error];
}

class _TimerTickEvent extends ActiveTableOrdersEvent {
  final Map<int, String> durations;

  const _TimerTickEvent(this.durations);

  @override
  List<Object?> get props => [durations];
}
