import 'package:equatable/equatable.dart';

class KitchenAggregatedItemEntity extends Equatable {
  final String itemName;
  final String? categoryName;
  final int? itemId;
  final String? remarks;
  final bool isParcel;
  final String? orderType;
  final int totalQuantity;
  final String status;

  const KitchenAggregatedItemEntity({
    required this.itemName,
    this.categoryName,
    this.itemId,
    this.remarks,
    this.isParcel = false,
    this.orderType,
    required this.totalQuantity,
    required this.status,
  });

  @override
  List<Object?> get props => [
        itemName,
        categoryName,
        itemId,
        remarks,
        isParcel,
        orderType,
        totalQuantity,
        status,
      ];
}
