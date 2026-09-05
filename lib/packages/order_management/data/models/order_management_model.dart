import 'dart:convert';
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
    super.subtotalAmount,
    super.discountAmount,
    super.taxAmount,
    super.taxPercentage,
    super.otherChargesAmount,
    super.cashReceivedAmount,
    super.changeAmount,
    super.taxDetailsList,
    super.discountDetailsList,
    super.chargeDetailsList,
  });

  factory OrderManagementModel.fromDrift(OrderWithItems orderWithItems) {
    final o = orderWithItems.order;
    final inv = orderWithItems.invoice;
    final itemModels = orderWithItems.items
        .map((i) => OrderItemManagementModel.fromDrift(i))
        .toList();

    final subtotal = itemModels.fold<double>(
      0.0,
      (sum, item) => sum + item.subTotal,
    );

    final double discount = inv?.discountAmount ?? 0.0;
    final double taxCost = inv?.taxCost ?? 0.0;
    final double taxPct = inv?.taxPercentage ?? 0.0;
    final double grandTotal = (inv != null && inv.netPaymentAmount > 0)
        ? inv.netPaymentAmount
        : (subtotal - discount + taxCost);

    final double calcDiff = grandTotal - (subtotal - discount + taxCost);
    final double otherCharges = calcDiff > 0.01 ? calcDiff : 0.0;

    List<Map<String, dynamic>> parsedTaxDetails = [];
    List<Map<String, dynamic>> parsedDiscountDetails = [];
    List<Map<String, dynamic>> parsedChargeDetails = [];

    double cashReceived = (inv?.cashReceived != null && inv!.cashReceived! > 0)
        ? inv.cashReceived!
        : ((o.cashReceived != null && o.cashReceived! > 0)
            ? o.cashReceived!
            : (inv?.recordAmountPaid ?? 0.0));
    double changeAmount = (inv?.changeAmount != null && inv!.changeAmount! > 0)
        ? inv.changeAmount!
        : (o.changeAmount ?? 0.0);

    final detailsStr = inv?.paymentMethodDetails ?? o.paymentMethodDetails;
    if (detailsStr != null && detailsStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(detailsStr);
        if (decoded is Map) {
          if (decoded.containsKey('cashReceived') && decoded['cashReceived'] != null) {
            cashReceived = (decoded['cashReceived'] as num).toDouble();
          }
          if (decoded.containsKey('changeAmount') && decoded['changeAmount'] != null) {
            changeAmount = (decoded['changeAmount'] as num).toDouble();
          }
          if (decoded.containsKey('taxDetails') && decoded['taxDetails'] is List) {
            parsedTaxDetails = List<Map<String, dynamic>>.from(
              (decoded['taxDetails'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            );
          }
          if (decoded.containsKey('discountDetails') && decoded['discountDetails'] is List) {
            parsedDiscountDetails = List<Map<String, dynamic>>.from(
              (decoded['discountDetails'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            );
          }
          if (decoded.containsKey('chargeDetails') && decoded['chargeDetails'] is List) {
            parsedChargeDetails = List<Map<String, dynamic>>.from(
              (decoded['chargeDetails'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            );
          }
        }
      } catch (_) {}
    }

    final paymentName = (o.paymentMethodName != null && o.paymentMethodName!.isNotEmpty)
        ? o.paymentMethodName
        : inv?.paymentMethodName;

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
      paymentMethodName: paymentName,
      paymentMethodDetails: o.paymentMethodDetails ?? inv?.paymentMethodDetails,
      deliveryAddress: o.deliveryAddress,
      customerId: o.customerId,
      customerName: o.customerName,
      phoneNumber: o.phoneNumber,
      isoCode: o.isoCode,
      reservationId: o.reservationId,
      items: itemModels,
      totalAmount: grandTotal,
      subtotalAmount: (o.subtotalAmount != null && o.subtotalAmount! > 0)
          ? o.subtotalAmount!
          : (inv?.totalCost != null && inv!.totalCost > 0 ? inv.totalCost : subtotal),
      discountAmount: (o.discountAmount != null && o.discountAmount! > 0)
          ? o.discountAmount!
          : discount,
      taxAmount: (o.taxAmount != null && o.taxAmount! > 0)
          ? o.taxAmount!
          : taxCost,
      taxPercentage: taxPct,
      otherChargesAmount: (o.otherChargesAmount != null && o.otherChargesAmount! > 0)
          ? o.otherChargesAmount!
          : otherCharges,
      cashReceivedAmount: cashReceived,
      changeAmount: changeAmount,
      taxDetailsList: parsedTaxDetails,
      discountDetailsList: parsedDiscountDetails,
      chargeDetailsList: parsedChargeDetails,
    );
  }
}
