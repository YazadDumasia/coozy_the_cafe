class StockAdjustment {
  final int? id;
  final String? hashId;
  final int? inventoryId;
  final String? inventoryName;
  final String? adjustmentType; // 'add' or 'remove'
  final double? adjustedQty;
  final double? previousStock;
  final double? newStock;
  final String? reason;
  final String? createdDate;

  const StockAdjustment({
    this.id,
    this.hashId,
    this.inventoryId,
    this.inventoryName,
    this.adjustmentType,
    this.adjustedQty,
    this.previousStock,
    this.newStock,
    this.reason,
    this.createdDate,
  });

  StockAdjustment copyWith({
    int? id,
    String? hashId,
    int? inventoryId,
    String? inventoryName,
    String? adjustmentType,
    double? adjustedQty,
    double? previousStock,
    double? newStock,
    String? reason,
    String? createdDate,
  }) {
    return StockAdjustment(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      inventoryId: inventoryId ?? this.inventoryId,
      inventoryName: inventoryName ?? this.inventoryName,
      adjustmentType: adjustmentType ?? this.adjustmentType,
      adjustedQty: adjustedQty ?? this.adjustedQty,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      reason: reason ?? this.reason,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAdjustment &&
          id == other.id &&
          hashId == other.hashId &&
          inventoryId == other.inventoryId &&
          inventoryName == other.inventoryName &&
          adjustmentType == other.adjustmentType &&
          adjustedQty == other.adjustedQty &&
          previousStock == other.previousStock &&
          newStock == other.newStock &&
          reason == other.reason &&
          createdDate == other.createdDate;

  @override
  int get hashCode => Object.hash(
    id,
    hashId,
    inventoryId,
    inventoryName,
    adjustmentType,
    adjustedQty,
    previousStock,
    newStock,
    reason,
    createdDate,
  );
}
