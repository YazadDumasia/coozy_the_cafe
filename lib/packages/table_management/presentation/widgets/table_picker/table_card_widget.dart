import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/table_entity.dart';

class TableCardWidget extends StatelessWidget {
  final TableEntity table;
  final VoidCallback? onTap;

  final String? elapsedTime;
  final String? elapsedCount;
  final String? cookingCount;
  final String? servedCount;
  final String? reservationInfo;

  const TableCardWidget({
    super.key,
    required this.table,
    this.onTap,
    this.elapsedTime,
    this.elapsedCount,
    this.cookingCount,
    this.servedCount,
    this.reservationInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final status = table.status;

    // Theme-aware colors matching design palette for light & dark mode
    Color headerBgColor;
    Color headerTextColor;

    switch (status) {
      case TableStatus.occupied:
      case TableStatus.pendingBill:
        headerBgColor = isDark
            ? const Color(0xFF2E7D32)
            : const Color(0xFF4CAF50); // Vibrant Green
        headerTextColor = Colors.white;
        break;
      case TableStatus.reserved:
        headerBgColor = isDark
            ? const Color(0xFFE65100)
            : const Color(0xFFFF9800); // Vibrant Amber
        headerTextColor = Colors.white;
        break;
      case TableStatus.empty:
        Color? customColor;
        if (table.colorValue != null && table.colorValue!.trim().isNotEmpty) {
          final hexString = table.colorValue!.replaceAll('#', '').trim();
          final val = int.tryParse(hexString, radix: 16);
          if (val != null) {
            customColor = Color(val | 0xFF000000);
          }
        }
        headerBgColor =
            customColor ??
            (isDark
                ? colorScheme.surfaceContainerHighest
                : const Color(0xFFEBEBEB));
        headerTextColor = (customColor != null)
            ? (customColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white)
            : Colors.white;
        break;
    }

    final tableNoDisplay =
        (table.tableNumber != null && table.tableNumber!.trim().isNotEmpty)
        ? table.tableNumber!.trim()
        : table.name.trim();

    final tablePrefix =
        context.tr(
          LocaleKeys.tableHeaderPrefix,
          track: TrackConstants.tablePageTrack,
        ) ??
        'TABLE';
    final tableHeaderTitle = '$tablePrefix - $tableNoDisplay'.toUpperCase();

    final cardBgColor = colorScheme.surface;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      color: cardBgColor,
      shadowColor: theme.shadowColor.withValues(alpha: isDark ? 0.3 : 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          color: cardBgColor,
          type: MaterialType.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Header Banner Box ---
                Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical:
                        24, // Vertical padding for taller header banner view
                  ),
                  color: headerBgColor,
                  child: Text(
                    tableHeaderTitle,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: headerTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.4,
                    ),
                  ).inExpandedRow(),
                ),

                // --- Body Content Box ---
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Status / Info Section
                      if (status == TableStatus.occupied ||
                          status == TableStatus.pendingBill) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 15,
                              color: onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                elapsedTime ?? '',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                  color: onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ] else if (status == TableStatus.reserved) ...[
                        Text(
                          context.tr(
                                LocaleKeys.reservedStatus,
                                track: TrackConstants.tablePageTrack,
                              ) ??
                              'RESERVED',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isDark
                                ? const Color(0xFFFFB74D)
                                : const Color(0xFFFF9800),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 14,
                              color: onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                reservationInfo ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                  color: onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        // Empty Table
                        Text(
                          context.tr(
                                LocaleKeys.emptyStatus,
                                track: TrackConstants.tablePageTrack,
                              ) ??
                              'EMPTY',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],

                      // Table Label (Bottom Text)
                      if (_hasValidTableLabel()) ...[
                        Text(
                          _buildDetailText(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12.5,
                            color: onSurfaceVariant,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],

                      // Bottom Row: Seating metrics or Chair count
                      if (status == TableStatus.occupied ||
                          status == TableStatus.pendingBill) ...[
                        Row(
                          children: [
                            _buildCountIndicator(
                              context: context,
                              count: elapsedCount ?? '2',
                              icon: Icons.hourglass_bottom,
                            ),
                            const SizedBox(width: 4),
                            _buildCountIndicator(
                              context: context,
                              count: cookingCount ?? '-',
                              icon: Icons.soup_kitchen_outlined,
                            ),
                            const SizedBox(width: 4),
                            _buildCountIndicator(
                              context: context,
                              count: servedCount ?? '-',
                              icon: Icons.dinner_dining_outlined,
                            ),
                          ],
                        ),
                      ] else ...[
                        if (table.nosOfChairs > 0)
                          Text(
                            '${context.tr(LocaleKeys.chairsLabel, track: TrackConstants.tablePageTrack) ?? "Chairs"}: ${table.nosOfChairs}',
                            style: TextStyle(
                              fontSize: 11,
                              color: onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountIndicator({
    required BuildContext context,
    required String count,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest
              : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Icon(icon, size: 16, color: colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  bool _hasValidTableLabel() {
    final label = table.name.trim();
    if (label.isEmpty) return false;
    return true;
  }

  String _buildDetailText() {
    return table.name.trim().toLowerCase();
  }
}
