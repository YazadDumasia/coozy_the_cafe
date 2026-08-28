import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/cart_item.dart';
import '../entities/customer_details.dart';

class OrderCheckoutData {
  final String orderId;
  final List<CartItem> items;
  final CustomerDetails customerDetails;

  const OrderCheckoutData({
    required this.orderId,
    required this.items,
    required this.customerDetails,
  });
}

abstract class CheckoutRepository {
  Future<Either<Failure, OrderCheckoutData>> getOrderCheckoutData(String orderId);
}
