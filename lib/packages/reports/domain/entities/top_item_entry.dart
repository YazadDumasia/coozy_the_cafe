class TopItemEntry {
  const TopItemEntry({
    required this.itemName,
    this.totalQuantity = 0,
    this.totalRevenue = 0,
    this.totalCost = 0,
  });

  factory TopItemEntry.fromMap(Map<String, dynamic> map) {
    return TopItemEntry(
      itemName: map['itemName'] as String? ?? '',
      totalQuantity: (map['totalQuantity'] as num?)?.toInt() ?? 0,
      totalRevenue: (map['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0,
    );
  }

  final String itemName;
  final int totalQuantity;
  final double totalRevenue;
  final double totalCost;

  double get profit => totalRevenue - totalCost;
}
