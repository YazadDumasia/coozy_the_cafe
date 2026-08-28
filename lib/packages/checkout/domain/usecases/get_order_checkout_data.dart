import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../repositories/checkout_repository.dart';

class GetOrderCheckoutData {
  final CheckoutRepository repository;

  const GetOrderCheckoutData(this.repository);

  Future<Either<Failure, OrderCheckoutData>> call(String orderId) {
    return repository.getOrderCheckoutData(orderId);
  }
}
