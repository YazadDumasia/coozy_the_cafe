import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/core/error/failures.dart';
import 'package:coozy_the_cafe/packages/core/usecases/usecase.dart';
import '../repositories/order_management_repository.dart';

class UpdateOrderStatusParams extends Equatable {
  final int orderId;
  final String status;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

class UpdateOrderStatusUseCase
    implements UseCase<void, UpdateOrderStatusParams> {
  final OrderManagementRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateOrderStatusParams params) {
    return repository.updateOrderStatus(
      orderId: params.orderId,
      status: params.status,
    );
  }
}
