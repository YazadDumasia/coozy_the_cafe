import 'package:flutter/material.dart';

import '../../../domain/entities/table_entity.dart';

class TableCardWidget extends StatelessWidget {
  final TableEntity table;
  final VoidCallback? onTap;

  const TableCardWidget({super.key, required this.table, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOccupied = table.status == TableStatus.occupied;
    final resolvedHeaderColor = _parseHexColor(
      table.colorValue,
      const Color(0xFFD9D9D9),
    );
    final cardBaseColor = isOccupied
        ? theme.primaryColor
        : const Color(0xFFE8E8E8);
    final bodyColor = Colors.white;
    final textColor = isOccupied ? Colors.white : Colors.black87;
    final secondaryTextColor = isOccupied
        ? Colors.white70
        : Colors.grey.shade700;
    final detailText = _buildDetailText();

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: cardBaseColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isOccupied ? 0.12 : 0.04,
                  ),
                  blurRadius: isOccupied ? 10 : 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? theme.primaryColor
                        : resolvedHeaderColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    'TABLE - ${table.name}'.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isOccupied ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bodyColor,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          table.status.label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isOccupied
                                ? theme.primaryColor
                                : Colors.black87,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          detailText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColor,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nos. of chairs: ${table.nosOfChairs}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildDetailText() {
    final name = table.name.trim();
    if (name.isEmpty) {
      return 'Table details';
    }

    return name.toLowerCase();
  }

  static Color _parseHexColor(String? value, Color fallbackColor) {
    if (value == null || value.trim().isEmpty) {
      return fallbackColor;
    }

    var hex = value.trim();
    hex = hex.replaceAll('#', '');
    hex = hex.replaceAll('0x', '').replaceAll('0X', '');

    if (hex.length == 3) {
      hex = hex.split('').expand((char) => [char, char]).join();
    }

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    if (hex.length != 8) {
      return fallbackColor;
    }

    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallbackColor;
    }
  }
}
