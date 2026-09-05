import 'package:equatable/equatable.dart';

class OrderItemManagementEntity extends Equatable {
  final int id;
  final int? orderId;
  final int? itemId;
  final String? itemName;
  final int quantity;
  final double sellingPrice;
  final double subTotal;
  final String? status;
  final String? notes;

  const OrderItemManagementEntity({
    required this.id,
    this.orderId,
    this.itemId,
    this.itemName,
    required this.quantity,
    required this.sellingPrice,
    required this.subTotal,
    this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        itemId,
        itemName,
        quantity,
        sellingPrice,
        subTotal,
        status,
        notes,
      ];
}

class OrderManagementEntity extends Equatable {
  final int id;
  final String hashId;
  final int? tableInfoId;
  final String? tableNameText;
  final String? creationDate;
  final String? modificationDate;
  final bool isCanceled;
  final bool isDeleted;
  final String status;
  final String? orderType;
  final String? paymentMethodName;
  final String? paymentMethodDetails;
  final String? deliveryAddress;
  final int? customerId;
  final String? customerName;
  final String? phoneNumber;
  final String? isoCode;
  final int? reservationId;
  final List<OrderItemManagementEntity> items;
  final double totalAmount;
  final double subtotalAmount;
  final double discountAmount;
  final double taxAmount;
  final double taxPercentage;
  final double otherChargesAmount;
  final double cashReceivedAmount;
  final double changeAmount;
  final List<Map<String, dynamic>> taxDetailsList;
  final List<Map<String, dynamic>> discountDetailsList;
  final List<Map<String, dynamic>> chargeDetailsList;

  const OrderManagementEntity({
    required this.id,
    required this.hashId,
    this.tableInfoId,
    this.tableNameText,
    this.creationDate,
    this.modificationDate,
    this.isCanceled = false,
    this.isDeleted = false,
    required this.status,
    this.orderType,
    this.paymentMethodName,
    this.paymentMethodDetails,
    this.deliveryAddress,
    this.customerId,
    this.customerName,
    this.phoneNumber,
    this.isoCode,
    this.reservationId,
    this.items = const [],
    required this.totalAmount,
    this.subtotalAmount = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.taxPercentage = 0.0,
    this.otherChargesAmount = 0.0,
    this.cashReceivedAmount = 0.0,
    this.changeAmount = 0.0,
    this.taxDetailsList = const [],
    this.discountDetailsList = const [],
    this.chargeDetailsList = const [],
  });

  @override
  List<Object?> get props => [
        id,
        hashId,
        tableInfoId,
        tableNameText,
        creationDate,
        modificationDate,
        isCanceled,
        isDeleted,
        status,
        orderType,
        paymentMethodName,
        paymentMethodDetails,
        deliveryAddress,
        customerId,
        customerName,
        phoneNumber,
        isoCode,
        reservationId,
        items,
        totalAmount,
        subtotalAmount,
        discountAmount,
        taxAmount,
        taxPercentage,
        otherChargesAmount,
        cashReceivedAmount,
        changeAmount,
        taxDetailsList,
        discountDetailsList,
        chargeDetailsList,
      ];
}
