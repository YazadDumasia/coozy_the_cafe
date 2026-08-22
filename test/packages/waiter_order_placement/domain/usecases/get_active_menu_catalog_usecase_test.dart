import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/menu_catalog_data.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/usecases/get_active_menu_catalog_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

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
  }) async {
    return const Right(101);
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
