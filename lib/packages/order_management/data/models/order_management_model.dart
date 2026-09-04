import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../../domain/entities/order_management_entity.dart';

class OrderItemManagementModel extends OrderItemManagementEntity {
  const OrderItemManagementModel({
    required super.id,
    super.orderId,
    super.itemId,
    super.itemName,
    required super.quantity,
    required super.sellingPrice,
    required super.subTotal,
    super.status,
    super.notes,
  });

  factory OrderItemManagementModel.fromDrift(OrderItem item) {
    final qty = item.quantity ?? 1;
    final price = item.sellingPrice ?? 0.0;
    return OrderItemManagementModel(
      id: item.id,
      orderId: item.orderId,
      itemId: item.itemId,
      itemName: 'Item #${item.itemId ?? item.id}',
      quantity: qty,
      sellingPrice: price,
      subTotal: price * qty,
      status: item.status,
      notes: item.remarks,

    );
  }
}

class OrderManagementModel extends OrderManagementEntity {
  const OrderManagementModel({
    required super.id,
    required super.hashId,
    super.tableInfoId,
    super.tableNameText,
    super.creationDate,
    super.modificationDate,
    super.isCanceled,
    super.isDeleted,
    required super.status,
    super.orderType,
    super.paymentMethodName,
    super.paymentMethodDetails,
    super.deliveryAddress,
    super.customerId,
    super.customerName,
    super.phoneNumber,
    super.isoCode,
    super.reservationId,
    super.items,
    required super.totalAmount,
  });

  factory OrderManagementModel.fromDrift(OrderWithItems orderWithItems) {
    final o = orderWithItems.order;
    final itemModels = orderWithItems.items
        .map((i) => OrderItemManagementModel.fromDrift(i))
        .toList();

    final total = itemModels.fold<double>(
      0.0,
      (sum, item) => sum + item.subTotal,
    );

    return OrderManagementModel(
      id: o.id,
      hashId: o.hashId,
      tableInfoId: o.tableInfoId,
      tableNameText: o.tableNameText,
      creationDate: o.creationDate,
      modificationDate: o.modificationDate,
      isCanceled: o.isCanceled ?? false,
      isDeleted: o.isDeleted ?? false,
      status: o.status ?? 'newOrder',
      orderType: o.orderType ?? 'Dine-In',
      paymentMethodName: o.paymentMethodName,
      paymentMethodDetails: o.paymentMethodDetails,
      deliveryAddress: o.deliveryAddress,
      customerId: o.customerId,
      customerName: o.customerName,
      phoneNumber: o.phoneNumber,
      isoCode: o.isoCode,
      reservationId: o.reservationId,
      items: itemModels,
      totalAmount: total,
    );
  }
}
