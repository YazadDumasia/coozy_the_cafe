import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/customer_loyalty_entity.dart';
import '../../../domain/usecases/customer_usecases.dart';

class CustomerLoyaltyModal extends StatelessWidget {
  const CustomerLoyaltyModal({super.key, required this.customer});

  final CustomerEntity customer;

  static void show(BuildContext context, CustomerEntity customer) {
    if (shared.ResponsiveLayout.isMobile(context)) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => CustomerLoyaltyModal(customer: customer),
      );
    } else {
      final isDesktop = shared.ResponsiveLayout.isDesktop(context);
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 650 : 540,
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
            ),
            child: SingleChildScrollView(
              child: CustomerLoyaltyModal(customer: customer),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final getLoyaltyUseCase = GetIt.I<GetCustomerLoyaltyUseCase>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                  child: Icon(Icons.stars_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name ?? 'Customer Loyalty',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        customer.phoneNumber ?? 'No Phone',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FutureBuilder<CustomerLoyaltyEntity?>(
              future:
                  customer.id != null
                      ? getLoyaltyUseCase(customer.id!)
                      : Future.value(null),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final loyalty =
                    snapshot.data ??
                    CustomerLoyaltyEntity(
                      customerId: customer.id ?? 0,
                      pointsBalance: 0,
                      lifetimePointsEarned: 0,
                      lifetimePointsRedeemed: 0,
                      tier: 'Bronze',
                      totalSpent: 0.0,
                      totalVisits: 0,
                    );

                Color tierColor;
                IconData tierIcon;
                switch (loyalty.tier.toLowerCase()) {
                  case 'vip':
                    tierColor = Colors.purple;
                    tierIcon = Icons.diamond_rounded;
                  case 'gold':
                    tierColor = Colors.amber.shade700;
                    tierIcon = Icons.workspace_premium_rounded;
                  case 'silver':
                    tierColor = Colors.blueGrey;
                    tierIcon = Icons.military_tech_rounded;
                  default:
                    tierColor = const Color(0xFFCD7F32); // Bronze
                    tierIcon = Icons.shield_rounded;
                }

                return Column(
                  children: [
                    // ── Tier & Points Card ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tierColor.withValues(alpha: isDark ? 0.35 : 0.2),
                            tierColor.withValues(alpha: isDark ? 0.15 : 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: tierColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(tierIcon, color: tierColor, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                '${loyalty.tier} Member',
                                style: TextStyle(
                                  color: tierColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${loyalty.pointsBalance} Pts',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: tierColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Redemption Value: ₹${loyalty.discountValueInRupees.toStringAsFixed(2)} off next bill',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Lifetime Stats ──────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _LoyaltyStatItem(
                            label: 'Lifetime Earned',
                            value: '${loyalty.lifetimePointsEarned} pts',
                            icon: Icons.add_circle_outline_rounded,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LoyaltyStatItem(
                            label: 'Lifetime Redeemed',
                            value: '${loyalty.lifetimePointsRedeemed} pts',
                            icon: Icons.remove_circle_outline_rounded,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _LoyaltyStatItem(
                            label: 'Total Spent',
                            value: '₹${loyalty.totalSpent.toStringAsFixed(0)}',
                            icon: Icons.payments_rounded,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LoyaltyStatItem(
                            label: 'Total Visits',
                            value: '${loyalty.totalVisits}',
                            icon: Icons.store_mall_directory_rounded,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // ── Recent Activity Section ─────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.history_rounded, size: 18, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Recent Activity',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: customer.id != null
                          ? GetIt.I<GetLoyaltyTransactionsUseCase>()(customer.id!)
                          : Future.value([]),
                      builder: (context, txSnapshot) {
                        if (txSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        final txList = txSnapshot.data ?? [];
                        if (txList.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.grey.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'No loyalty transactions yet.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          );
                        }

                        return ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: txList.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final tx = txList[index];
                              final isEarned = (tx['transaction_type'] as String?) == 'EARNED';
                              final pts = (tx['points'] as num?)?.toInt() ?? 0;
                              final date = (tx['created_date'] as String?) ?? '';
                              final notes = (tx['notes'] as String?) ?? (isEarned ? 'Earned' : 'Redeemed');

                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isEarned
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.orange.withValues(alpha: 0.15),
                                  child: Icon(
                                    isEarned ? Icons.add : Icons.remove,
                                    size: 14,
                                    color: isEarned ? Colors.green : Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  notes,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                subtitle: Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                  ),
                                ),
                                trailing: Text(
                                  '${isEarned ? '+' : '-'}$pts pts',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isEarned ? Colors.green : Colors.orange,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoyaltyStatItem extends StatelessWidget {
  const _LoyaltyStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
