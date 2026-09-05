import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';

class InvoiceEntity extends Equatable {
  final int id;
  final int? orderId;
  final String hashId;
  final double taxPercentage;
  final int discountType;
  final double discountAmount;
  final double totalCost;
  final double taxCost;
  final double taxableAmount;
  final double netPaymentAmount;
  final String? createdDate;
  final String? modifiedDate;
  final int? customerId;
  final String? customerName;
  final String? phoneNumber;
  final String? isoCode;
  final int? paymentModeId;
  final String? paymentMethodName;
  final double recordAmountPaid;
  final String? paymentMethodDetails;
  final double? cashReceived;
  final double? changeAmount;

  const InvoiceEntity({
    required this.id,
    this.orderId,
    required this.hashId,
    this.taxPercentage = 0.0,
    this.discountType = 0,
    this.discountAmount = 0.0,
    this.totalCost = 0.0,
    this.taxCost = 0.0,
    this.taxableAmount = 0.0,
    this.netPaymentAmount = 0.0,
    this.createdDate,
    this.modifiedDate,
    this.customerId,
    this.customerName,
    this.phoneNumber,
    this.isoCode,
    this.paymentModeId,
    this.paymentMethodName,
    this.recordAmountPaid = 0.0,
    this.paymentMethodDetails,
    this.cashReceived,
    this.changeAmount,
  });

  factory InvoiceEntity.fromDrift(Invoice data) {
    return InvoiceEntity(
      id: data.id,
      orderId: data.orderId,
      hashId: data.hashId,
      taxPercentage: data.taxPercentage,
      discountType: data.discountType,
      discountAmount: data.discountAmount,
      totalCost: data.totalCost,
      taxCost: data.taxCost,
      taxableAmount: data.taxableAmount,
      netPaymentAmount: data.netPaymentAmount,
      createdDate: data.createdDate,
      modifiedDate: data.modifiedDate,
      customerId: data.customerId,
      customerName: data.customerName,
      phoneNumber: data.phoneNumber,
      isoCode: data.isoCode,
      paymentModeId: data.paymentModeId,
      paymentMethodName: data.paymentMethodName,
      recordAmountPaid: data.recordAmountPaid,
      paymentMethodDetails: data.paymentMethodDetails,
      cashReceived: data.cashReceived,
      changeAmount: data.changeAmount,
    );
  }

  InvoiceEntity copyWith({
    int? id,
    int? orderId,
    String? hashId,
    double? taxPercentage,
    int? discountType,
    double? discountAmount,
    double? totalCost,
    double? taxCost,
    double? taxableAmount,
    double? netPaymentAmount,
    String? createdDate,
    String? modifiedDate,
    int? customerId,
    String? customerName,
    String? phoneNumber,
    String? isoCode,
    int? paymentModeId,
    String? paymentMethodName,
    double? recordAmountPaid,
    String? paymentMethodDetails,
    double? cashReceived,
    double? changeAmount,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      hashId: hashId ?? this.hashId,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      discountType: discountType ?? this.discountType,
      discountAmount: discountAmount ?? this.discountAmount,
      totalCost: totalCost ?? this.totalCost,
      taxCost: taxCost ?? this.taxCost,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      netPaymentAmount: netPaymentAmount ?? this.netPaymentAmount,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isoCode: isoCode ?? this.isoCode,
      paymentModeId: paymentModeId ?? this.paymentModeId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      recordAmountPaid: recordAmountPaid ?? this.recordAmountPaid,
      paymentMethodDetails: paymentMethodDetails ?? this.paymentMethodDetails,
      cashReceived: cashReceived ?? this.cashReceived,
      changeAmount: changeAmount ?? this.changeAmount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        hashId,
        taxPercentage,
        discountType,
        discountAmount,
        totalCost,
        taxCost,
        taxableAmount,
        netPaymentAmount,
        createdDate,
        modifiedDate,
        customerId,
        customerName,
        phoneNumber,
        isoCode,
        paymentModeId,
        paymentMethodName,
        recordAmountPaid,
        paymentMethodDetails,
        cashReceived,
        changeAmount,
      ];
}

class InvoiceItemEntity extends Equatable {
  final int id;
  final int? invoiceId;
  final int? orderItemId;
  final int? itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const InvoiceItemEntity({
    required this.id,
    this.invoiceId,
    this.orderItemId,
    this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory InvoiceItemEntity.fromDrift(InvoiceItem data) {
    return InvoiceItemEntity(
      id: data.id,
      invoiceId: data.invoiceId,
      orderItemId: data.orderItemId,
      itemId: data.itemId,
      itemName: data.itemName ?? '',
      quantity: data.quantity ?? 1,
      unitPrice: data.sellingPrice ?? 0.0,
      totalPrice: data.totalPrice ?? 0.0,
    );
  }

  InvoiceItemEntity copyWith({
    int? id,
    int? invoiceId,
    int? orderItemId,
    int? itemId,
    String? itemName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return InvoiceItemEntity(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      orderItemId: orderItemId ?? this.orderItemId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        orderItemId,
        itemId,
        itemName,
        quantity,
        unitPrice,
        totalPrice,
      ];
}

class InvoiceDetailsEntity extends Equatable {
  final InvoiceEntity invoice;
  final List<InvoiceItemEntity> items;
  final List<PaymentTransaction> paymentTransactions;
  final String? tableName;

  const InvoiceDetailsEntity({
    required this.invoice,
    required this.items,
    this.paymentTransactions = const [],
    this.tableName,
  });

  int get totalItemTypes => items.length;
  int get totalUnits => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [invoice, items, paymentTransactions, tableName];
}

class PaginatedInvoicesEntity extends Equatable {
  final List<InvoiceEntity> invoices;
  final int totalCount;

  const PaginatedInvoicesEntity({
    required this.invoices,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [invoices, totalCount];
}
