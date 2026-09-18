import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class CashFlowSummaryCard extends StatelessWidget {
  final double netCashFlow;
  final double totalIncome;
  final double totalExpense;

  const CashFlowSummaryCard({
    super.key,
    required this.netCashFlow,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final incomeColor = isDark
        ? Colors.greenAccent[400]!
        : const Color(0xFF2E7D32);
    final expenseColor = isDark
        ? Colors.redAccent[200]!
        : const Color(0xFFD32F2F);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Net Cash Flow Section
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: Column(
              children: [
                Text(
                  context.tr(
                        shared.LocaleKeys.expenditureNetCashFlow,
                        track: shared.TrackConstants.expenditurePageTrack,
                      ) ??
                      'Net Cash Flow',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  netCashFlow >= 0
                      ? core.CurrencyFormatter.format(value: netCashFlow)
                      : '- ${core.CurrencyFormatter.format(value: netCashFlow.abs())}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: netCashFlow >= 0 ? incomeColor : expenseColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(
                        shared.LocaleKeys.expenditureFormulaNote,
                        track: shared.TrackConstants.expenditurePageTrack,
                      ) ??
                      '(Total Income - Total Expense)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Split Income and Expense Row
          IntrinsicHeight(
            child: Row(
              children: [
                // Income Column
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Text(
                          context.tr(
                                shared.LocaleKeys.expenditureIncome,
                                track:
                                    shared.TrackConstants.expenditurePageTrack,
                              ) ??
                              'Income',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          core.CurrencyFormatter.format(value: totalIncome),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: incomeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                // Expense Column
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Text(
                          context.tr(
                                shared.LocaleKeys.expenditureExpense,
                                track:
                                    shared.TrackConstants.expenditurePageTrack,
                              ) ??
                              'Expense',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          core.CurrencyFormatter.format(value: totalExpense),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: expenseColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
