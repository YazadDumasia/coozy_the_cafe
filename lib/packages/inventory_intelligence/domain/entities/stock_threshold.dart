import 'package:equatable/equatable.dart';

class StockThreshold extends Equatable {
  final int? id;
  final String? hashId;
  final int inventoryId;
  final String inventoryName;
  final double minThreshold;
  final double reorderQuantity;
  final bool autoReorder;
  final String? preferredSupplier;
  final double? estimatedCost;
  final String? updatedDate;

  const StockThreshold({
    this.id,
    this.hashId,
    required this.inventoryId,
    required this.inventoryName,
    this.minThreshold = 5.0,
    this.reorderQuantity = 20.0,
    this.autoReorder = true,
    this.preferredSupplier,
    this.estimatedCost,
    this.updatedDate,
  });

  StockThreshold copyWith({
    int? id,
    String? hashId,
    int? inventoryId,
    String? inventoryName,
    double? minThreshold,
    double? reorderQuantity,
    bool? autoReorder,
    String? preferredSupplier,
    double? estimatedCost,
    String? updatedDate,
  }) {
    return StockThreshold(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      inventoryId: inventoryId ?? this.inventoryId,
      inventoryName: inventoryName ?? this.inventoryName,
      minThreshold: minThreshold ?? this.minThreshold,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      autoReorder: autoReorder ?? this.autoReorder,
      preferredSupplier: preferredSupplier ?? this.preferredSupplier,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    inventoryId,
    inventoryName,
    minThreshold,
    reorderQuantity,
    autoReorder,
    preferredSupplier,
    estimatedCost,
    updatedDate,
  ];
}
