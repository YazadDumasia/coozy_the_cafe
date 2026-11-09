import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/entities/stock_alert.dart';

class StockAlertCard extends StatelessWidget {
  final StockAlert alert;
  final VoidCallback? onReorder;
  final VoidCallback? onDismiss;
  final VoidCallback? onConfigureThreshold;

  const StockAlertCard({
    super.key,
    required this.alert,
    this.onReorder,
    this.onDismiss,
    this.onConfigureThreshold,
  });

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.outOfStock:
        return Colors.red.shade700;
      case AlertSeverity.critical:
        return Colors.deepOrange.shade600;
      case AlertSeverity.warning:
        return Colors.amber.shade800;
    }
  }

  String _getSeverityLabel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.outOfStock:
        return 'OUT OF STOCK';
      case AlertSeverity.critical:
        return 'CRITICAL DEFICIT';
      case AlertSeverity.warning:
        return 'LOW STOCK';
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.outOfStock:
        return Icons.error_outline_rounded;
      case AlertSeverity.critical:
        return Icons.warning_amber_rounded;
      case AlertSeverity.warning:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final severityColor = _getSeverityColor(alert.severity);

    // Compute progress ratio (currentStock / minThreshold)
    final progress = alert.minThreshold > 0
        ? (alert.currentStock / alert.minThreshold).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: severityColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Severity badge, item name, and configure icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: severityColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getSeverityIcon(alert.severity),
                        size: 14,
                        color: severityColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getSeverityLabel(alert.severity),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: severityColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (onConfigureThreshold != null)
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, size: 20),
                    tooltip: 'Adjust Safety Threshold',
                    onPressed: onConfigureThreshold,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Item Name and Unit
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.inventoryName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Unit: ${alert.purchaseUnit != null && alert.purchaseUnit!.isNotEmpty ? alert.purchaseUnit : 'pcs'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stock progress indicators
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              children: [
                                const TextSpan(text: 'Current: '),
                                TextSpan(
                                  text: '${alert.currentStock}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: severityColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Min Threshold: ${alert.minThreshold}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            severityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Suggested Reorder details & Action Buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deficit: ${alert.deficit} ${alert.purchaseUnit ?? ''}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
                const SizedBox(width: 8),
                if (onReorder != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: onReorder,
                    icon: const Icon(
                      Icons.shopping_cart_checkout_rounded,
                      size: 16,
                    ),
                    label: const Text('1-Click Reorder'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
