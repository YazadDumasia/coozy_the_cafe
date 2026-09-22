class InventoryStockEntry {
  const InventoryStockEntry({
    required this.id,
    required this.name,
    this.currentStock = 0.0,
    this.purchaseUnit = '',
    this.isEnabled = true,
  });

  factory InventoryStockEntry.fromMap(Map<String, dynamic> map) {
    return InventoryStockEntry(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? '',
      currentStock: (map['currentStock'] as num?)?.toDouble() ?? 0.0,
      purchaseUnit: map['purchaseUnit'] as String? ?? '',
      isEnabled: (map['isEnabled'] == 1 || map['isEnabled'] == true),
    );
  }

  final int id;
  final String name;
  final double currentStock;
  final String purchaseUnit;
  final bool isEnabled;
}
