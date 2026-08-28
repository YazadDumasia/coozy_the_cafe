import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/customer_details.dart';
import '../../domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final OrdersDao ordersDao;

  CheckoutRepositoryImpl({required this.ordersDao});

  @override
  Future<Either<Failure, OrderCheckoutData>> getOrderCheckoutData(String orderId) async {
    try {
      final parsedId = int.tryParse(orderId);
      if (parsedId == null) {
        return Left(DatabaseFailure(message: 'Invalid Order ID format: $orderId'));
      }

      final orderInfo = await ordersDao.getOrderInfo(parsedId);
      if (orderInfo == null) {
        return Left(DatabaseFailure(message: 'Order with ID $orderId not found'));
      }


      final cartItems = orderInfo.items.map((item) {
        return CartItem(
          id: item.id.toString(),
          name: 'Item #${item.itemId ?? item.id}',
          quantity: item.quantity ?? 1,
          unitPrice: item.sellingPrice ?? 0.0,
          itemDiscount: 0.0,
        );
      }).toList();

      final customerDetails = CustomerDetails(
        name: orderInfo.order.customerName ?? '',
        mobileNumber: orderInfo.order.phoneNumber ?? '',
      );

      return Right(
        OrderCheckoutData(
          orderId: orderId,
          items: cartItems,
          customerDetails: customerDetails,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }

  }
}

