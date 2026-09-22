class SalesDashboard {
  const SalesDashboard({
    this.totalInvoices = 0,
    this.totalSales = 0,
    this.totalTax = 0,
    this.totalDiscount = 0,
    this.netTotal = 0,
    this.averageOrderValue = 0,
    this.totalCost = 0,
    this.totalProfit = 0,
    this.profitPercentage,
  });

  factory SalesDashboard.fromMap(Map<String, dynamic> map) {
    return SalesDashboard(
      totalInvoices: (map['totalInvoices'] as num?)?.toInt() ?? 0,
      totalSales: (map['totalSales'] as num?)?.toDouble() ?? 0,
      totalTax: (map['totalTax'] as num?)?.toDouble() ?? 0,
      totalDiscount: (map['totalDiscount'] as num?)?.toDouble() ?? 0,
      netTotal: (map['netTotal'] as num?)?.toDouble() ?? 0,
      averageOrderValue: (map['averageOrderValue'] as num?)?.toDouble() ?? 0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0,
      totalProfit: (map['totalProfit'] as num?)?.toDouble() ?? 0,
      profitPercentage: (map['profitPercentage'] as num?)?.toDouble(),
    );
  }

  final int totalInvoices;
  final double totalSales;
  final double totalTax;
  final double totalDiscount;
  final double netTotal;
  final double averageOrderValue;
  final double totalCost;
  final double totalProfit;
  final double? profitPercentage;

  static SalesDashboard empty() => const SalesDashboard();
}
