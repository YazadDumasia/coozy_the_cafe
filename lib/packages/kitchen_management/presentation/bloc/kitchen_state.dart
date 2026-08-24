part of 'kitchen_bloc.dart';

enum KitchenViewMode { tickets, aggregated }

sealed class KitchenState extends Equatable {
  const KitchenState();

  @override
  List<Object?> get props => [];
}

class KitchenInitialState extends KitchenState {
  const KitchenInitialState();
}

class KitchenLoadingState extends KitchenState {
  const KitchenLoadingState();
}

class KitchenLoadedState extends KitchenState {
  final List<KitchenOrderEntity> orders;
  final List<KitchenAggregatedItemEntity> aggregatedItems;
  final KitchenViewMode viewMode;
  final String statusFilter; // 'all', 'pending', 'preparing'

  const KitchenLoadedState({
    required this.orders,
    required this.aggregatedItems,
    this.viewMode = KitchenViewMode.tickets,
    this.statusFilter = 'all',
  });

  KitchenLoadedState copyWith({
    List<KitchenOrderEntity>? orders,
    List<KitchenAggregatedItemEntity>? aggregatedItems,
    KitchenViewMode? viewMode,
    String? statusFilter,
  }) {
    return KitchenLoadedState(
      orders: orders ?? this.orders,
      aggregatedItems: aggregatedItems ?? this.aggregatedItems,
      viewMode: viewMode ?? this.viewMode,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  List<KitchenOrderEntity> get filteredOrders {
    if (statusFilter == 'all') return orders;
    return orders.where((order) {
      return order.items.any((item) => item.status == statusFilter);
    }).toList();
  }

  int get totalActiveOrders => orders.length;

  int get pendingItemsCount => orders.fold(
        0,
        (sum, order) =>
            sum +
            order.items
                .where((i) => i.status == 'pending' || i.status == 'preparing')
                .length,
      );

  @override
  List<Object?> get props => [orders, aggregatedItems, viewMode, statusFilter];
}

class KitchenErrorState extends KitchenState {
  final String message;

  const KitchenErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
