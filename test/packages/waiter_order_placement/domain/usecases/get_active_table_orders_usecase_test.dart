import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/active_table_order.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/menu_catalog_data.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/get_active_table_orders_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_details.dart';

class MockWaiterOrderPlacementRepository
    implements WaiterOrderPlacementRepository {
  final List<ActiveTableOrder> mockOrders;

  MockWaiterOrderPlacementRepository(this.mockOrders);

  @override
  Future<Either<Failure, List<ActiveTableOrder>>> getActiveTableOrders() async {
    return Right(mockOrders);
  }

  @override
  Stream<List<ActiveTableOrder>> watchActiveTableOrders() {
    return Stream.value(mockOrders);
  }

  @override
  Future<Either<Failure, void>> deleteTableOrder(int orderId) async {
    return const Right(null);
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
  Future<Either<Failure, OrderDetails>> getOrderDetails(int orderId) async {
    throw UnimplementedError();
  }
}

void main() {
  test('should return list of active table orders from repository', () async {
    const mockOrder = ActiveTableOrder(
      orderId: 1,
      tableId: 4,
      tableName: 'TABLE - TABLE 4',
      tableShape: 'RECTANGLE',
      tableLocationNotes: 'middle table',
      pendingItemCount: 1,
    );
    final mockRepository = MockWaiterOrderPlacementRepository([mockOrder]);
    final useCase = GetActiveTableOrdersUseCase(mockRepository);

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Expected Right but got Left'),
      (orders) {
        expect(orders.length, equals(1));
        expect(orders.first.tableName, equals('TABLE - TABLE 4'));
        expect(orders.first.pendingItemCount, equals(1));
      },
    );
  });
}
