import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/error/failures.dart';
import '../entities/order_management_entity.dart';

class PaginatedOrdersResult {
  final List<OrderManagementEntity> orders;
  final int totalCount;

  const PaginatedOrdersResult({
    required this.orders,
    required this.totalCount,
  });
}

abstract class OrderManagementRepository {
  Future<Either<Failure, PaginatedOrdersResult>> getPaginatedOrders({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? status,
  });

  Future<Either<Failure, OrderManagementEntity?>> getOrderInfo(int orderId);

  Future<Either<Failure, void>> updateOrderStatus({
    required int orderId,
    required String status,
  });
}
