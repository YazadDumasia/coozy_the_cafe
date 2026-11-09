import 'package:equatable/equatable.dart';

enum AlertSeverity {
  warning,
  critical,
  outOfStock;

  static AlertSeverity fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'out_of_stock':
      case 'outofstock':
        return AlertSeverity.outOfStock;
      default:
        return AlertSeverity.warning;
    }
  }

  String get displayName {
    switch (this) {
      case AlertSeverity.warning:
        return 'Low Stock Warning';
      case AlertSeverity.critical:
        return 'Critical Shortage';
      case AlertSeverity.outOfStock:
        return 'Out of Stock';
    }
  }
}

enum AlertStatus {
  active,
  reordered,
  dismissed;

  static AlertStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'reordered':
        return AlertStatus.reordered;
      case 'dismissed':
        return AlertStatus.dismissed;
      default:
        return AlertStatus.active;
    }
  }
}

class StockAlert extends Equatable {
  final int? id;
  final String? hashId;
  final int inventoryId;
  final String inventoryName;
  final double currentStock;
  final double minThreshold;
  final String? purchaseUnit;
  final AlertSeverity severity;
  final AlertStatus status;
  final String? createdDate;
  final String? resolvedDate;
  final String? remarks;

  const StockAlert({
    this.id,
    this.hashId,
    required this.inventoryId,
    required this.inventoryName,
    required this.currentStock,
    required this.minThreshold,
    this.purchaseUnit,
    this.severity = AlertSeverity.warning,
    this.status = AlertStatus.active,
    this.createdDate,
    this.resolvedDate,
    this.remarks,
  });

  /// Stock deficit = threshold - current stock
  double get deficit =>
      (minThreshold - currentStock).clamp(0.0, double.infinity);

  StockAlert copyWith({
    int? id,
    String? hashId,
    int? inventoryId,
    String? inventoryName,
    double? currentStock,
    double? minThreshold,
    String? purchaseUnit,
    AlertSeverity? severity,
    AlertStatus? status,
    String? createdDate,
    String? resolvedDate,
    String? remarks,
  }) {
    return StockAlert(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      inventoryId: inventoryId ?? this.inventoryId,
      inventoryName: inventoryName ?? this.inventoryName,
      currentStock: currentStock ?? this.currentStock,
      minThreshold: minThreshold ?? this.minThreshold,
      purchaseUnit: purchaseUnit ?? this.purchaseUnit,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    inventoryId,
    inventoryName,
    currentStock,
    minThreshold,
    purchaseUnit,
    severity,
    status,
    createdDate,
    resolvedDate,
    remarks,
  ];
}
