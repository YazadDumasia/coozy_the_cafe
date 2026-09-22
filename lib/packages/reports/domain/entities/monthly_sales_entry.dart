class MonthlySalesEntry {
  const MonthlySalesEntry({
    required this.saleMonth,
    this.totalInvoices = 0,
    this.totalSales = 0,
    this.totalTax = 0,
    this.totalDiscount = 0,
    this.netTotal = 0,
    this.monthlyCost = 0,
    this.monthlyProfit = 0,
    this.profitPercentage,
  });

  factory MonthlySalesEntry.fromMap(Map<String, dynamic> map) {
    return MonthlySalesEntry(
      saleMonth: map['saleMonth'] as String? ?? '',
      totalInvoices: (map['totalInvoices'] as num?)?.toInt() ?? 0,
      totalSales: (map['totalSales'] as num?)?.toDouble() ?? 0,
      totalTax: (map['totalTax'] as num?)?.toDouble() ?? 0,
      totalDiscount: (map['totalDiscount'] as num?)?.toDouble() ?? 0,
      netTotal: (map['netTotal'] as num?)?.toDouble() ?? 0,
      monthlyCost: (map['monthlyCost'] as num?)?.toDouble() ?? 0,
      monthlyProfit: (map['monthlyProfit'] as num?)?.toDouble() ?? 0,
      profitPercentage: (map['profitPercentage'] as num?)?.toDouble(),
    );
  }

  final String saleMonth;
  final int totalInvoices;
  final double totalSales;
  final double totalTax;
  final double totalDiscount;
  final double netTotal;
  final double monthlyCost;
  final double monthlyProfit;
  final double? profitPercentage;
}
