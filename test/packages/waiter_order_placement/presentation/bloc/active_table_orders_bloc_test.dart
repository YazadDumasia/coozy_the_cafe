import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/active_table_order.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/delete_table_order_usecase.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/get_active_table_orders_usecase.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/active_table_orders_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';
import '../../domain/usecases/get_active_table_orders_usecase_test.dart';

class MockDeleteTableOrderUseCase implements DeleteTableOrderUseCase {
  @override
  late final WaiterOrderPlacementRepository repository;

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    return const Right(null);
  }
}

void main() {
  late ActiveTableOrdersBloc bloc;
  late GetActiveTableOrdersUseCase getActiveTableOrdersUseCase;
  late DeleteTableOrderUseCase deleteTableOrderUseCase;

  const mockOrder = ActiveTableOrder(
    orderId: 1,
    tableId: 4,
    tableName: 'TABLE - TABLE 4',
    tableShape: 'RECTANGLE',
    tableLocationNotes: 'middle table',
    pendingItemCount: 1,
  );

  setUp(() {
    final repository = MockWaiterOrderPlacementRepository([mockOrder]);
    getActiveTableOrdersUseCase = GetActiveTableOrdersUseCase(repository);
    deleteTableOrderUseCase = MockDeleteTableOrderUseCase();
    bloc = ActiveTableOrdersBloc(
      getActiveTableOrdersUseCase: getActiveTableOrdersUseCase,
      deleteTableOrderUseCase: deleteTableOrderUseCase,
    );
  });

  test('initial state should be ActiveTableOrdersInitial', () {
    expect(bloc.state, equals(const ActiveTableOrdersInitial()));
  });

  test('should emit [ActiveTableOrdersLoading, ActiveTableOrdersLoaded] when LoadActiveTableOrdersEvent is added', () async {
    expectLater(
      bloc.stream,
      emitsInOrder([
        isA<ActiveTableOrdersLoading>(),
        isA<ActiveTableOrdersLoaded>(),
      ]),
    );

    bloc.add(const LoadActiveTableOrdersEvent());
  });
}
