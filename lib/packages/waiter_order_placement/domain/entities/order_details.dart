import 'package:equatable/equatable.dart';
import 'order_cart_item.dart';

class OrderDetails extends Equatable {
  final int orderId;
  final int? tableId;
  final String tableName;
  final List<OrderCartItem> cartItems;

  const OrderDetails({
    required this.orderId,
    this.tableId,
    required this.tableName,
    required this.cartItems,
  });

  @override
  List<Object?> get props => [orderId, tableId, tableName, cartItems];
}
