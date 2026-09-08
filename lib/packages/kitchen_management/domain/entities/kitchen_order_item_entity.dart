import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart' show OrderItemStatus;

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
  final String? placedAt;
  final String? preparationStartedAt;
  final String? readyAt;
  final String? servedAt;

  OrderItemStatus get orderItemStatus => OrderItemStatus.fromString(status);

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
    this.placedAt,
    this.preparationStartedAt,
    this.readyAt,
    this.servedAt,
  });

  /// Waiting duration before preparation begins
  Duration? get waitingDuration {
    final start = placedAt != null ? DateTime.tryParse(placedAt!) : null;
    final end = preparationStartedAt != null
        ? DateTime.tryParse(preparationStartedAt!)
        : (readyAt != null ? DateTime.tryParse(readyAt!) : null);
    if (start != null && end != null) {
      final diff = end.difference(start);
      return diff.isNegative ? Duration.zero : diff;
    }
    return null;
  }

  /// Active preparation duration in kitchen
  Duration? get preparationDuration {
    final start = preparationStartedAt != null
        ? DateTime.tryParse(preparationStartedAt!)
        : null;
    final end = readyAt != null ? DateTime.tryParse(readyAt!) : null;
    if (start != null && end != null) {
      final diff = end.difference(start);
      return diff.isNegative ? Duration.zero : diff;
    }
    return null;
  }

  /// Waiting period between food being ready and served to customer
  Duration? get servingWaitingDuration {
    final start = readyAt != null ? DateTime.tryParse(readyAt!) : null;
    final end = servedAt != null ? DateTime.tryParse(servedAt!) : null;
    if (start != null && end != null) {
      final diff = end.difference(start);
      return diff.isNegative ? Duration.zero : diff;
    }
    return null;
  }

  /// Total duration from order placed to served
  Duration? get totalDuration {
    final start = placedAt != null ? DateTime.tryParse(placedAt!) : null;
    final end = servedAt != null ? DateTime.tryParse(servedAt!) : null;
    if (start != null && end != null) {
      final diff = end.difference(start);
      return diff.isNegative ? Duration.zero : diff;
    }
    return null;
  }

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
    String? placedAt,
    String? preparationStartedAt,
    String? readyAt,
    String? servedAt,
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
      placedAt: placedAt ?? this.placedAt,
      preparationStartedAt: preparationStartedAt ?? this.preparationStartedAt,
      readyAt: readyAt ?? this.readyAt,
      servedAt: servedAt ?? this.servedAt,
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
    placedAt,
    preparationStartedAt,
    readyAt,
    servedAt,
  ];
}
