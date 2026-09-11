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


      final db = ordersDao.attachedDatabase;
      final cartItems = await Future.wait(orderInfo.items.map((item) async {
        final menuItemId = item.menuItemId ?? item.itemId;
        String name = '';
        if (menuItemId != null) {
          final menuItem = await (db.select(db.menuItemsTable)
                ..where((m) => m.id.equals(menuItemId)))
              .getSingleOrNull();
          if (menuItem != null && menuItem.name.isNotEmpty) {
            name = menuItem.name;
          }
          if (item.selectedVariationId != null) {
            final variation = await (db.select(db.menuItemVariationsTable)
                  ..where((v) => v.id.equals(item.selectedVariationId!)))
                .getSingleOrNull();
            if (variation != null && variation.name != null && variation.name!.isNotEmpty) {
              name = name.isNotEmpty ? '$name (${variation.name})' : variation.name!;
            }
          }
        }
        if (name.isEmpty) {
          name = 'Item #${menuItemId ?? item.id}';
        }
        return CartItem(
          id: item.id.toString(),
          name: name,
          quantity: item.quantity ?? 1,
          unitPrice: item.sellingPrice ?? 0.0,
          itemDiscount: 0.0,
        );
      }));

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

