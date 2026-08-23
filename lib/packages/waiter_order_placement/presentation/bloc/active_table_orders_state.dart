part of 'active_table_orders_bloc.dart';

sealed class ActiveTableOrdersState extends Equatable {
  const ActiveTableOrdersState();

  @override
  List<Object?> get props => [];
}

class ActiveTableOrdersInitial extends ActiveTableOrdersState {
  const ActiveTableOrdersInitial();
}

class ActiveTableOrdersLoading extends ActiveTableOrdersState {
  const ActiveTableOrdersLoading();
}

class ActiveTableOrdersLoaded extends ActiveTableOrdersState {
  final List<ActiveTableOrder> orders;
  final Map<int, String> orderDurations;

  const ActiveTableOrdersLoaded({
    required this.orders,
    this.orderDurations = const {},
  });

  @override
  List<Object?> get props => [orders, orderDurations];
}

class ActiveTableOrdersError extends ActiveTableOrdersState {
  final String message;

  const ActiveTableOrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}
