import 'package:equatable/equatable.dart';

class PurchaseSummary extends Equatable {
  final double dailyTotal;
  final double weeklyTotal;
  final double monthlyTotal;

  const PurchaseSummary({
    required this.dailyTotal,
    required this.weeklyTotal,
    required this.monthlyTotal,
  });

  @override
  List<Object?> get props => [dailyTotal, weeklyTotal, monthlyTotal];
}
