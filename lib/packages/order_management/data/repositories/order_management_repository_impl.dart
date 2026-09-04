import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/error/failures.dart';
import '../../domain/entities/order_management_entity.dart';
import '../../domain/repositories/order_management_repository.dart';
import '../datasources/order_management_local_data_source.dart';

class OrderManagementRepositoryImpl implements OrderManagementRepository {
  final OrderManagementLocalDataSource localDataSource;

  OrderManagementRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, PaginatedOrdersResult>> getPaginatedOrders({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? status,
  }) async {
    try {
      final (models, count) = await localDataSource.getPaginatedOrders(
        limit: limit,
        pageNo: pageNo,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        status: status,
      );
      return Right(
        PaginatedOrdersResult(
          orders: models,
          totalCount: count,
        ),
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderManagementEntity?>> getOrderInfo(
      int orderId) async {
    try {
      final model = await localDataSource.getOrderInfo(orderId);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      await localDataSource.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
