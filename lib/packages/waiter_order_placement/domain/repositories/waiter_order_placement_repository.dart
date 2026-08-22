import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../entities/menu_catalog_data.dart';
import '../entities/order_cart_item.dart';

abstract class WaiterOrderPlacementRepository {
  Future<Either<Failure, MenuCatalogData>> getActiveMenuCatalog();
  Future<Either<Failure, int>> submitOrder({
    required int tableId,
    required String tableName,
    required List<OrderCartItem> cartItems,
  });
}
