part of 'kitchen_bloc.dart';

sealed class KitchenEvent extends Equatable {
  const KitchenEvent();

  @override
  List<Object?> get props => [];
}

class LoadKitchenOrdersEvent extends KitchenEvent {
  const LoadKitchenOrdersEvent();
}

class ToggleViewModeEvent extends KitchenEvent {
  final KitchenViewMode viewMode;

  const ToggleViewModeEvent(this.viewMode);

  @override
  List<Object?> get props => [viewMode];
}

class UpdateItemStatusEvent extends KitchenEvent {
  final int orderItemId;
  final String newStatus;

  const UpdateItemStatusEvent({
    required this.orderItemId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderItemId, newStatus];
}

class BumpAllOrderItemsEvent extends KitchenEvent {
  final int orderId;
  final String newStatus;

  const BumpAllOrderItemsEvent({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderId, newStatus];
}

class FilterStatusChangedEvent extends KitchenEvent {
  final String statusFilter; // 'all', 'pending', 'preparing'

  const FilterStatusChangedEvent(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}

class _KitchenOrdersUpdatedEvent extends KitchenEvent {
  final List<KitchenOrderEntity> orders;

  const _KitchenOrdersUpdatedEvent(this.orders);

  @override
  List<Object?> get props => [orders];
}
