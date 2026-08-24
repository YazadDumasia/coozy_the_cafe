import 'package:equatable/equatable.dart';
import 'kitchen_order_item_entity.dart';

class KitchenOrderEntity extends Equatable {
  final int id;
  final int? tableInfoId;
  final String? tableNameText;
  final String? creationDate;
  final String? status;
  final String? orderType; // Dine-In, Takeaway, Parcel, Delivery
  final String? customerName;
  final List<KitchenOrderItemEntity> items;

  const KitchenOrderEntity({
    required this.id,
    this.tableInfoId,
    this.tableNameText,
    this.creationDate,
    this.status,
    this.orderType,
    this.customerName,
    required this.items,
  });

  bool get hasPendingOrPreparingItems => items.any(
    (item) => item.status == 'pending' || item.status == 'preparing',
  );

  @override
  List<Object?> get props => [
    id,
    tableInfoId,
    tableNameText,
    creationDate,
    status,
    orderType,
    customerName,
    items,
  ];
}
