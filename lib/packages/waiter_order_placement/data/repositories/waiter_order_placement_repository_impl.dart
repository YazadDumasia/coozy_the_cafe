import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/menu_catalog_data.dart';
import '../../domain/entities/order_cart_item.dart';
import '../../domain/repositories/waiter_order_placement_repository.dart';
import '../datasources/waiter_order_placement_local_datasource.dart';

class WaiterOrderPlacementRepositoryImpl
    implements WaiterOrderPlacementRepository {
  final WaiterOrderPlacementLocalDataSource localDataSource;

  WaiterOrderPlacementRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, MenuCatalogData>> getActiveMenuCatalog() async {
    try {
      final catalogData = await localDataSource.getActiveMenuCatalog();
      return Right(catalogData);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> submitOrder({
    required int tableId,
    required String tableName,
    required List<OrderCartItem> cartItems,
  }) async {
    try {
      final orderId = await localDataSource.submitOrder(
        tableId: tableId,
        tableName: tableName,
        cartItems: cartItems,
      );
      return Right(orderId);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
