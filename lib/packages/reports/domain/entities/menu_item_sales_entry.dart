class MenuItemSalesEntry {
  const MenuItemSalesEntry({
    required this.itemName,
    required this.saleDate,
    this.quantitySold = 0,
    this.totalAmount = 0.0,
    this.totalCost = 0.0,
    this.totalProfit = 0.0,
    this.profitPercentage,
  });

  factory MenuItemSalesEntry.fromMap(Map<String, dynamic> map) {
    return MenuItemSalesEntry(
      itemName: map['itemName'] as String? ?? '',
      saleDate: map['saleDate'] as String? ?? '',
      quantitySold: (map['quantitySold'] as num?)?.toInt() ?? 0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (map['totalProfit'] as num?)?.toDouble() ?? 0.0,
      profitPercentage: (map['profitPercentage'] as num?)?.toDouble(),
    );
  }

  final String itemName;
  final String saleDate;
  final int quantitySold;
  final double totalAmount;
  final double totalCost;
  final double totalProfit;
  final double? profitPercentage;
}
