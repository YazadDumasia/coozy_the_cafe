import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart' show OrderStatus;
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
  final String? placedAt;
  final String? preparationStartedAt;
  final String? readyAt;
  final String? servedAt;

  OrderStatus get orderStatus => OrderStatus.fromString(status);

  const KitchenOrderEntity({
    required this.id,
    this.tableInfoId,
    this.tableNameText,
    this.creationDate,
    this.status,
    this.orderType,
    this.customerName,
    required this.items,
    this.placedAt,
    this.preparationStartedAt,
    this.readyAt,
    this.servedAt,
  });

  bool get hasPendingOrPreparingItems => items.any(
    (item) => item.status == 'pending' || item.status == 'preparing',
  );

  /// Waiting duration before kitchen started preparing the order
  Duration? get waitingDuration {
    final start = placedAt != null
        ? DateTime.tryParse(placedAt!)
        : (creationDate != null ? DateTime.tryParse(creationDate!) : null);
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

  /// Waiting duration between order ready and order served
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
    final start = placedAt != null
        ? DateTime.tryParse(placedAt!)
        : (creationDate != null ? DateTime.tryParse(creationDate!) : null);
    final end = servedAt != null ? DateTime.tryParse(servedAt!) : null;
    if (start != null && end != null) {
      final diff = end.difference(start);
      return diff.isNegative ? Duration.zero : diff;
    }
    return null;
  }

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
    placedAt,
    preparationStartedAt,
    readyAt,
    servedAt,
  ];
}
