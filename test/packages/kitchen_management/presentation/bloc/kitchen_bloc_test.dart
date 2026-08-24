import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/kitchen_management.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/domain/repositories/kitchen_repository.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/domain/usecases/get_active_kitchen_orders_usecase.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/domain/usecases/get_aggregated_pending_items_usecase.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/domain/usecases/update_all_order_items_status_usecase.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/domain/usecases/update_order_item_status_usecase.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/domain/usecases/watch_active_kitchen_orders_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class MockKitchenRepository implements KitchenRepository {
  final List<KitchenOrderEntity> mockOrders;

  MockKitchenRepository(this.mockOrders);

  @override
  Future<Either<Failure, List<KitchenOrderEntity>>> getActiveKitchenOrders() async {
    return Right(mockOrders);
  }

  @override
  Stream<List<KitchenOrderEntity>> watchActiveKitchenOrders() {
    return Stream.value(mockOrders);
  }

  @override
  Future<Either<Failure, bool>> updateOrderItemStatus({
    required int orderItemId,
    required String status,
  }) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, int>> updateAllOrderItemsStatus({
    required int orderId,
    required String status,
  }) async {
    return const Right(1);
  }

  @override
  Future<Either<Failure, List<KitchenAggregatedItemEntity>>> getAggregatedPendingItems() async {
    return const Right([
      KitchenAggregatedItemEntity(
        itemName: 'Cappuccino',
        totalQuantity: 2,
        status: 'pending',
      ),
    ]);
  }
}

void main() {
  late KitchenBloc kitchenBloc;
  late MockKitchenRepository repository;

  final mockOrders = [
    const KitchenOrderEntity(
      id: 1,
      tableNameText: 'Table 1',
      items: [
        KitchenOrderItemEntity(
          id: 101,
          itemName: 'Espresso',
          quantity: 1,
          status: 'pending',
        ),
      ],
    ),
  ];

  setUp(() {
    repository = MockKitchenRepository(mockOrders);
    kitchenBloc = KitchenBloc(
      getActiveKitchenOrdersUseCase: GetActiveKitchenOrdersUseCase(repository),
      watchActiveKitchenOrdersUseCase: WatchActiveKitchenOrdersUseCase(repository),
      updateOrderItemStatusUseCase: UpdateOrderItemStatusUseCase(repository),
      updateAllOrderItemsStatusUseCase: UpdateAllOrderItemsStatusUseCase(repository),
      getAggregatedPendingItemsUseCase: GetAggregatedPendingItemsUseCase(repository),
    );
  });

  tearDown(() {
    kitchenBloc.close();
  });

  test('initial state should be KitchenInitialState', () {
    expect(kitchenBloc.state, equals(const KitchenInitialState()));
  });

  test('emits KitchenLoadedState when live stream updates', () async {
    final expectedState = const KitchenLoadedState(
      orders: [
        KitchenOrderEntity(
          id: 1,
          tableNameText: 'Table 1',
          items: [
            KitchenOrderItemEntity(
              id: 101,
              itemName: 'Espresso',
              quantity: 1,
              status: 'pending',
            ),
          ],
        ),
      ],
      aggregatedItems: [
        KitchenAggregatedItemEntity(
          itemName: 'Cappuccino',
          totalQuantity: 2,
          status: 'pending',
        ),
      ],
    );

    expectLater(kitchenBloc.stream, emits(expectedState));
  });
}
