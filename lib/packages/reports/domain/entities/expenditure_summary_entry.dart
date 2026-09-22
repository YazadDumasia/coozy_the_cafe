class ExpenditureSummaryEntry {
  const ExpenditureSummaryEntry({
    required this.type,
    required this.categoryName,
    this.totalAmount = 0.0,
    this.transactionCount = 0,
  });

  factory ExpenditureSummaryEntry.fromMap(Map<String, dynamic> map) {
    return ExpenditureSummaryEntry(
      type: map['type'] as String? ?? 'EXPENSE',
      categoryName: map['categoryName'] as String? ?? 'General',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (map['transactionCount'] as num?)?.toInt() ?? 0,
    );
  }

  final String type; // 'EXPENSE' or 'INCOME'
  final String categoryName;
  final double totalAmount;
  final int transactionCount;
}
