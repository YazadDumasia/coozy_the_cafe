class PurchaseSummaryEntry {
  const PurchaseSummaryEntry({
    required this.itemName,
    this.purchaseUnit = '',
    this.totalQty = 0.0,
    this.totalCost = 0.0,
  });

  factory PurchaseSummaryEntry.fromMap(Map<String, dynamic> map) {
    return PurchaseSummaryEntry(
      itemName: map['itemName'] as String? ?? '',
      purchaseUnit: map['purchaseUnit'] as String? ?? '',
      totalQty: (map['totalQty'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String itemName;
  final String purchaseUnit;
  final double totalQty;
  final double totalCost;
}
