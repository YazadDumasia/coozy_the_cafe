import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/active_table_order.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/menu_catalog_data.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_details.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/get_order_details_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class MockWaiterOrderPlacementRepository
    implements WaiterOrderPlacementRepository {
  final OrderDetails expectedDetails;

  MockWaiterOrderPlacementRepository(this.expectedDetails);

  @override
  Future<Either<Failure, OrderDetails>> getOrderDetails(int orderId) async {
    return Right(expectedDetails);
  }

  @override
  Future<Either<Failure, MenuCatalogData>> getActiveMenuCatalog() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, int>> submitOrder({
    required int tableId,
    required String tableName,
    required List<OrderCartItem> cartItems,
    int? orderId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ActiveTableOrder>>> getActiveTableOrders() async {
    throw UnimplementedError();
  }

  @override
  Stream<List<ActiveTableOrder>> watchActiveTableOrders() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteTableOrder(int orderId) async {
    throw UnimplementedError();
  }
}

void main() {
  test('should return order details from repository by orderId', () async {
    const expectedDetails = OrderDetails(
      orderId: 10,
      tableId: 2,
      tableName: 'TABLE 2',
      cartItems: [
        OrderCartItem(
          menuItemId: 1,
          name: 'Water Bottle',
          price: 20.0,
          quantity: 2,
        ),
      ],
    );

    final mockRepository = MockWaiterOrderPlacementRepository(expectedDetails);
    final useCase = GetOrderDetailsUseCase(mockRepository);

    final result = await useCase(10);

    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Expected Right but got Left'),
      (details) {
        expect(details.orderId, equals(10));
        expect(details.tableId, equals(2));
        expect(details.tableName, equals('TABLE 2'));
        expect(details.cartItems.length, equals(1));
        expect(details.cartItems.first.name, equals('Water Bottle'));
      },
    );
  });
}
