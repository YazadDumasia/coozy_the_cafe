import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/kitchen_management.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/domain/repositories/kitchen_repository.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/domain/usecases/get_active_kitchen_orders_usecase.dart';
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
    return const Right([]);
  }
}

void main() {
  test('should return active kitchen orders from repository', () async {
    final mockOrders = [
      const KitchenOrderEntity(
        id: 1,
        tableNameText: 'Table 5',
        orderType: 'Dine-In',
        items: [
          KitchenOrderItemEntity(
            id: 10,
            itemName: 'Cappuccino',
            quantity: 2,
            status: 'pending',
          ),
        ],
      ),
    ];

    final repository = MockKitchenRepository(mockOrders);
    final useCase = GetActiveKitchenOrdersUseCase(repository);

    final result = await useCase();

    expect(result, isA<Right<Failure, List<KitchenOrderEntity>>>());
    result.fold(
      (l) => fail('Should succeed'),
      (orders) {
        expect(orders.length, equals(1));
        expect(orders.first.id, equals(1));
        expect(orders.first.tableNameText, equals('Table 5'));
        expect(orders.first.items.first.itemName, equals('Cappuccino'));
      },
    );
  });
}
