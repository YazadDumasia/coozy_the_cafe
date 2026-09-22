class DailySalesEntry {
  const DailySalesEntry({
    required this.saleDate,
    this.totalInvoices = 0,
    this.totalSales = 0,
    this.totalTax = 0,
    this.totalDiscount = 0,
    this.netTotal = 0,
    this.dailyCost = 0,
    this.dailyProfit = 0,
    this.profitPercentage,
  });

  factory DailySalesEntry.fromMap(Map<String, dynamic> map) {
    return DailySalesEntry(
      saleDate: map['saleDate'] as String? ?? '',
      totalInvoices: (map['totalInvoices'] as num?)?.toInt() ?? 0,
      totalSales: (map['totalSales'] as num?)?.toDouble() ?? 0,
      totalTax: (map['totalTax'] as num?)?.toDouble() ?? 0,
      totalDiscount: (map['totalDiscount'] as num?)?.toDouble() ?? 0,
      netTotal: (map['netTotal'] as num?)?.toDouble() ?? 0,
      dailyCost: (map['dailyCost'] as num?)?.toDouble() ?? 0,
      dailyProfit: (map['dailyProfit'] as num?)?.toDouble() ?? 0,
      profitPercentage: (map['profitPercentage'] as num?)?.toDouble(),
    );
  }

  final String saleDate;
  final int totalInvoices;
  final double totalSales;
  final double totalTax;
  final double totalDiscount;
  final double netTotal;
  final double dailyCost;
  final double dailyProfit;
  final double? profitPercentage;
}
