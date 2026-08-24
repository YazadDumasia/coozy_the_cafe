import 'package:equatable/equatable.dart';

class KitchenOrderItemEntity extends Equatable {
  final int id;
  final int? orderId;
  final int? itemId;
  final String itemName;
  final int quantity;
  final String status; // pending, preparing, ready, served
  final String? remarks;
  final bool isParcel;
  final String? variationQuantity;
  final String? variationUnit;

  const KitchenOrderItemEntity({
    required this.id,
    this.orderId,
    this.itemId,
    required this.itemName,
    required this.quantity,
    required this.status,
    this.remarks,
    this.isParcel = false,
    this.variationQuantity,
    this.variationUnit,
  });

  KitchenOrderItemEntity copyWith({
    int? id,
    int? orderId,
    int? itemId,
    String? itemName,
    int? quantity,
    String? status,
    String? remarks,
    bool? isParcel,
    String? variationQuantity,
    String? variationUnit,
  }) {
    return KitchenOrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      isParcel: isParcel ?? this.isParcel,
      variationQuantity: variationQuantity ?? this.variationQuantity,
      variationUnit: variationUnit ?? this.variationUnit,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        itemId,
        itemName,
        quantity,
        status,
        remarks,
        isParcel,
        variationQuantity,
        variationUnit,
      ];
}
