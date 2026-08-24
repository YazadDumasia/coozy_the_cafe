import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/active_table_order.dart';
import '../../domain/usecases/delete_table_order_usecase.dart';
import '../../domain/usecases/get_active_table_orders_usecase.dart';

part 'active_table_orders_event.dart';
part 'active_table_orders_state.dart';

class DurationComputeParams {
  final Map<int, String> orderCreationDates;
  final String nowIso;

  const DurationComputeParams({
    required this.orderCreationDates,
    required this.nowIso,
  });
}

Map<int, String> calculateOrderDurationsIsolate(DurationComputeParams params) {
  final now = DateTime.parse(params.nowIso);
  final resultMap = <int, String>{};

  params.orderCreationDates.forEach((orderId, isoDate) {
    if (isoDate.isEmpty) {
      resultMap[orderId] = '0m:0s';
      return;
    }
    final creationDate = DateTime.tryParse(isoDate)?.toLocal();
    if (creationDate == null) {
      resultMap[orderId] = '0m:0s';
      return;
    }
    final diff = now.difference(creationDate);
    if (diff.isNegative) {
      resultMap[orderId] = '0m:0s';
      return;
    }
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    if (hours > 0) {
      resultMap[orderId] = '${hours}h:${minutes}m:${seconds}s';
    } else {
      resultMap[orderId] = '${minutes}m:${seconds}s';
    }
  });

  return resultMap;
}

class ActiveTableOrdersBloc
    extends Bloc<ActiveTableOrdersEvent, ActiveTableOrdersState> {
  final GetActiveTableOrdersUseCase getActiveTableOrdersUseCase;
  final DeleteTableOrderUseCase deleteTableOrderUseCase;

  StreamSubscription<List<ActiveTableOrder>>? _ordersSubscription;
  Timer? _tickerTimer;
  List<ActiveTableOrder> _currentOrders = [];

  ActiveTableOrdersBloc({
    required this.getActiveTableOrdersUseCase,
    required this.deleteTableOrderUseCase,
  }) : super(const ActiveTableOrdersInitial()) {
    on<LoadActiveTableOrdersEvent>(_onLoadActiveTableOrders);
    on<DeleteTableOrderEvent>(_onDeleteTableOrder);
    on<_ActiveTableOrdersUpdatedEvent>(_onOrdersUpdated);
    on<_TimerTickEvent>(_onTimerTick);
  }

  Future<void> _onLoadActiveTableOrders(
    LoadActiveTableOrdersEvent event,
    Emitter<ActiveTableOrdersState> emit,
  ) async {
    emit(const ActiveTableOrdersLoading());
    await _ordersSubscription?.cancel();
    _ordersSubscription = getActiveTableOrdersUseCase.watch().listen(
      (orders) {
        add(_ActiveTableOrdersUpdatedEvent(orders));
      },
      onError: (error) {
        add(_ActiveTableOrdersUpdatedEvent(const [], error: error.toString()));
      },
    );
  }

  Future<void> _onOrdersUpdated(
    _ActiveTableOrdersUpdatedEvent event,
    Emitter<ActiveTableOrdersState> emit,
  ) async {
    if (event.error != null) {
      _stopTicker();
      emit(ActiveTableOrdersError(message: event.error!));
    } else {
      _currentOrders = event.orders;
      final durations = await _computeDurations(_currentOrders);
      emit(
        ActiveTableOrdersLoaded(
          orders: event.orders,
          orderDurations: durations,
        ),
      );
      _startTicker();
    }
  }

  void _onTimerTick(
    _TimerTickEvent event,
    Emitter<ActiveTableOrdersState> emit,
  ) {
    if (state is ActiveTableOrdersLoaded) {
      final currentLoaded = state as ActiveTableOrdersLoaded;
      emit(
        ActiveTableOrdersLoaded(
          orders: currentLoaded.orders,
          orderDurations: event.durations,
        ),
      );
    }
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    if (_currentOrders.isEmpty) return;

    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_currentOrders.isNotEmpty) {
        final durations = await _computeDurations(_currentOrders);
        if (!isClosed) {
          add(_TimerTickEvent(durations));
        }
      }
    });
  }

  void _stopTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
  }

  Future<Map<int, String>> _computeDurations(
    List<ActiveTableOrder> orders,
  ) async {
    final creationDatesMap = <int, String>{};
    for (final o in orders) {
      if (o.creationDate != null) {
        creationDatesMap[o.orderId] = o.creationDate!.toIso8601String();
      }
    }

    final params = DurationComputeParams(
      orderCreationDates: creationDatesMap,
      nowIso: DateTime.now().toIso8601String(),
    );

    return await compute(calculateOrderDurationsIsolate, params);
  }

  Future<void> _onDeleteTableOrder(
    DeleteTableOrderEvent event,
    Emitter<ActiveTableOrdersState> emit,
  ) async {
    final result = await deleteTableOrderUseCase(event.orderId);
    result.fold(
      (failure) => emit(ActiveTableOrdersError(message: failure.message)),
      (_) => null,
    );
  }

  @override
  Future<void> close() {
    _stopTicker();
    _ordersSubscription?.cancel();
    return super.close();
  }
}
