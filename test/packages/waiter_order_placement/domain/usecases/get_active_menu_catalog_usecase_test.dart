import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/active_table_order.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/menu_catalog_data.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/get_active_menu_catalog_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_details.dart';

class MockWaiterOrderPlacementRepository
    implements WaiterOrderPlacementRepository {
  @override
  Future<Either<Failure, MenuCatalogData>> getActiveMenuCatalog() async {
    const category = Category(
      id: 1,
      hashId: 'cat-1',
      name: 'Coffee',
      isActive: true,
      position: 1,
    );
    const catalog = MenuCatalogData(
      activeCategories: [category],
      categoryDataList: [
        MenuCatalogCategoryData(
          category: category,
          subcategories: [],
          uncategorizedItems: [],
          subcategoryItems: {},
        ),
      ],
    );
    return const Right(catalog);
  }

  @override
  Future<Either<Failure, int>> submitOrder({
    required int tableId,
    required String tableName,
    required List<OrderCartItem> cartItems,
    int? orderId,
  }) async {
    return const Right(101);
  }

  @override
  Future<Either<Failure, OrderDetails>> getOrderDetails(int orderId) async {
    return Right(
      OrderDetails(
        orderId: orderId,
        tableId: 1,
        tableName: 'Table 1',
        cartItems: const [],
      ),
    );
  }

  @override
  Future<Either<Failure, List<ActiveTableOrder>>> getActiveTableOrders() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> deleteTableOrder(int orderId) async {
    return const Right(null);
  }

  @override
  Stream<List<ActiveTableOrder>> watchActiveTableOrders() {
    return Stream.value([]);
  }
}

void main() {
  late GetActiveMenuCatalogUseCase useCase;
  late MockWaiterOrderPlacementRepository mockRepository;

  setUp(() {
    mockRepository = MockWaiterOrderPlacementRepository();
    useCase = GetActiveMenuCatalogUseCase(mockRepository);
  });

  test('should return active menu catalog data from repository', () async {
    final result = await useCase();
    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Expected Right but got Left: ${failure.message}'),
      (catalog) {
        expect(catalog.activeCategories.length, equals(1));
        expect(catalog.activeCategories.first.name, equals('Coffee'));
      },
    );
  });
}
