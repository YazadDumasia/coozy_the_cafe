import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/error/failures.dart';
import 'package:coozy_the_cafe/packages/core/usecases/usecase.dart';
import '../entities/order_management_entity.dart';
import '../repositories/order_management_repository.dart';

class GetOrderInfoUseCase
    implements UseCase<OrderManagementEntity?, int> {
  final OrderManagementRepository repository;

  GetOrderInfoUseCase(this.repository);

  @override
  Future<Either<Failure, OrderManagementEntity?>> call(int orderId) {
    return repository.getOrderInfo(orderId);
  }
}
