import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../../domain/entities/expenditure_entity.dart';

class CashFlowTimelineItem extends StatelessWidget {
  final ExpenditureEntity item;
  final bool isLast;
  final VoidCallback? onDelete;

  const CashFlowTimelineItem({
    super.key,
    required this.item,
    this.isLast = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isIncome = item.type == 'INCOME';
    final sign = isIncome ? '+ ' : '- ';
    final amountColor = isIncome
        ? (isDark ? Colors.greenAccent[400]! : const Color(0xFF2E7D32))
        : (isDark ? Colors.redAccent[200]! : const Color(0xFFD32F2F));

    final avatarBgColor = isIncome
        ? (isDark ? const Color(0xFF1B3B2B) : const Color(0xFFE8F5E9))
        : (isDark ? const Color(0xFF3E2020) : const Color(0xFFFFEBEE));

    final avatarTextColor = isIncome
        ? (isDark ? Colors.greenAccent[400]! : const Color(0xFF2E7D32))
        : (isDark ? Colors.redAccent[200]! : const Color(0xFFD32F2F));

    final initialLetter = item.categoryName.isNotEmpty
        ? item.categoryName.trim()[0].toUpperCase()
        : '?';

    final connectorColor = colorScheme.outlineVariant.withValues(alpha: 0.5);

    return TimelineTile(
      nodeAlign: TimelineNodeAlign.start,
      contents: Padding(
        padding: const EdgeInsets.only(left: 8, right: 16, top: 4, bottom: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: isDark ? 0.15 : 0.03,
                ),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular initial letter avatar
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: avatarBgColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initialLetter,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: avatarTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Category name + party/note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.categoryName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.partyName != null && item.partyName!.isNotEmpty
                          ? item.partyName!
                          : (item.notes != null && item.notes!.isNotEmpty
                                ? item.notes!
                                : (context.tr(
                                        shared.LocaleKeys.homePageCoozyTheCafe,
                                        track:
                                            shared.TrackConstants.homePageTrack,
                                      ) ??
                                      'Coozy The Cafe')),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount
              Text(
                '$sign${core.CurrencyFormatter.format(value: item.amount)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
      node: TimelineNode(
        indicator: OutlinedDotIndicator(
          color: colorScheme.primary,
          size: 14,
          borderWidth: 2,
        ),
        startConnector: SolidLineConnector(
          color: connectorColor,
          thickness: 2.0,
          space: 24,
        ),
        endConnector: isLast
            ? null
            : SolidLineConnector(
                color: connectorColor,
                thickness: 2.0,
                space: 24,
              ),
      ),
    );
  }
}
