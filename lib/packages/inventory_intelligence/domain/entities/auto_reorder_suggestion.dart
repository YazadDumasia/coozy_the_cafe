import 'package:equatable/equatable.dart';

class AutoReorderSuggestion extends Equatable {
  final int inventoryId;
  final String inventoryName;
  final String? purchaseUnit;
  final double currentStock;
  final double minThreshold;
  final double suggestedReorderQty;
  final String? preferredSupplier;
  final double? estimatedUnitCost;

  const AutoReorderSuggestion({
    required this.inventoryId,
    required this.inventoryName,
    this.purchaseUnit,
    required this.currentStock,
    required this.minThreshold,
    required this.suggestedReorderQty,
    this.preferredSupplier,
    this.estimatedUnitCost,
  });

  double get estimatedTotalCost =>
      suggestedReorderQty * (estimatedUnitCost ?? 0.0);

  @override
  List<Object?> get props => [
    inventoryId,
    inventoryName,
    purchaseUnit,
    currentStock,
    minThreshold,
    suggestedReorderQty,
    preferredSupplier,
    estimatedUnitCost,
  ];
}
