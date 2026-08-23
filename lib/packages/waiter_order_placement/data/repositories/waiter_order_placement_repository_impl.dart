import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/menu_catalog_data.dart';
import '../../domain/entities/order_cart_item.dart';
import '../../domain/repositories/waiter_order_placement_repository.dart';
import '../datasources/waiter_order_placement_local_datasource.dart';

import '../../domain/entities/active_table_order.dart';

import '../../domain/entities/order_details.dart';

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
    int? orderId,
  }) async {
    try {
      final resOrderId = await localDataSource.submitOrder(
        tableId: tableId,
        tableName: tableName,
        cartItems: cartItems,
        orderId: orderId,
      );
      return Right(resOrderId);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderDetails>> getOrderDetails(int orderId) async {
    try {
      final orderDetails = await localDataSource.getOrderDetails(orderId);
      return Right(orderDetails);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActiveTableOrder>>> getActiveTableOrders() async {
    try {
      final orders = await localDataSource.getActiveTableOrders();
      return Right(orders);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ActiveTableOrder>> watchActiveTableOrders() {
    return localDataSource.watchActiveTableOrders();
  }

  @override
  Future<Either<Failure, void>> deleteTableOrder(int orderId) async {
    try {
      await localDataSource.deleteTableOrder(orderId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
