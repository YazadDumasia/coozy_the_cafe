import 'package:flutter/material.dart';
import '../../../../domain/entities/report_category.dart';

class ReportCategoryCard extends StatelessWidget {
  const ReportCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final ReportCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accentColor = _accentFor(category.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.12),
                scheme.surfaceContainerLow,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(category.icon, color: accentColor, size: 26),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                      size: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                category.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                category.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _accentFor(ReportType type) => switch (type) {
    ReportType.dailySales => const Color(0xFF6C63FF),
    ReportType.monthlySales => const Color(0xFF00BFA5),
    ReportType.topSellingItems => const Color(0xFFFF6B35),
    ReportType.paymentModes => const Color(0xFF2979FF),
    ReportType.salesDashboard => const Color(0xFFAB47BC),
    ReportType.inventoryStock => const Color(0xFF0288D1),
    ReportType.purchases => const Color(0xFFE64A19),
    ReportType.expenditure => const Color(0xFF43A047),
    ReportType.menuItemSales => const Color(0xFF8E24AA),
  };
}
