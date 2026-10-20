import 'package:equatable/equatable.dart';

class CustomerLoyaltyEntity extends Equatable {
  const CustomerLoyaltyEntity({
    required this.customerId,
    this.pointsBalance = 0,
    this.lifetimePointsEarned = 0,
    this.lifetimePointsRedeemed = 0,
    this.tier = 'Bronze',
    this.totalSpent = 0.0,
    this.totalVisits = 0,
    this.lastVisitDate,
    this.exchangeRate = 0.50,
  });

  factory CustomerLoyaltyEntity.fromMap(Map<String, dynamic> map, {double exchangeRate = 0.50}) {
    return CustomerLoyaltyEntity(
      customerId: (map['customer_id'] as num).toInt(),
      pointsBalance: (map['points_balance'] as num?)?.toInt() ?? 0,
      lifetimePointsEarned:
          (map['lifetime_points_earned'] as num?)?.toInt() ?? 0,
      lifetimePointsRedeemed:
          (map['lifetime_points_redeemed'] as num?)?.toInt() ?? 0,
      tier: (map['tier'] as String?) ?? 'Bronze',
      totalSpent: (map['total_spent'] as num?)?.toDouble() ?? 0.0,
      totalVisits: (map['total_visits'] as num?)?.toInt() ?? 0,
      lastVisitDate: map['last_visit_date'] as String?,
      exchangeRate: exchangeRate,
    );
  }

  final int customerId;
  final int pointsBalance;
  final int lifetimePointsEarned;
  final int lifetimePointsRedeemed;
  final String tier; // Bronze, Silver, Gold, VIP
  final double totalSpent;
  final int totalVisits;
  final String? lastVisitDate;
  final double exchangeRate;

  /// Approximate rupee discount value of the points based on exchange rate (defaults to 1 point = ₹0.50)
  double get discountValueInRupees => pointsBalance * exchangeRate;

  @override
  List<Object?> get props => [
    customerId,
    pointsBalance,
    lifetimePointsEarned,
    lifetimePointsRedeemed,
    tier,
    totalSpent,
    totalVisits,
    lastVisitDate,
  ];
}
