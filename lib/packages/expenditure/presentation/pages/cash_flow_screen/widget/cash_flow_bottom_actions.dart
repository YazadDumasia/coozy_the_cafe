import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class CashFlowBottomActions extends StatelessWidget {
  final VoidCallback onIncomeTap;
  final VoidCallback onExpenseTap;

  const CashFlowBottomActions({
    super.key,
    required this.onIncomeTap,
    required this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final incomeBtnColor = isDark
        ? const Color(0xFF2E7D32)
        : const Color(0xFF43A047);
    final expenseBtnColor = isDark
        ? const Color(0xFFC62828)
        : const Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Income Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onIncomeTap,
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: Text(
                  context.tr(
                        shared.LocaleKeys.expenditureIncome,
                        track: shared.TrackConstants.expenditurePageTrack,
                      ) ??
                      'Income',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: incomeBtnColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Expense Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onExpenseTap,
                icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                label: Text(
                  context.tr(
                        shared.LocaleKeys.expenditureExpense,
                        track: shared.TrackConstants.expenditurePageTrack,
                      ) ??
                      'Expense',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: expenseBtnColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
