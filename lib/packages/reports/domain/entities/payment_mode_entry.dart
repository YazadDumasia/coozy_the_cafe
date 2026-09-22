class PaymentModeEntry {
  const PaymentModeEntry({
    required this.paymentMethodName,
    this.transactionCount = 0,
    this.totalAmount = 0,
  });

  factory PaymentModeEntry.fromMap(Map<String, dynamic> map) {
    return PaymentModeEntry(
      paymentMethodName: map['paymentMethodName'] as String? ?? 'Unknown',
      transactionCount: (map['transactionCount'] as num?)?.toInt() ?? 0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  final String paymentMethodName;
  final int transactionCount;
  final double totalAmount;
}
