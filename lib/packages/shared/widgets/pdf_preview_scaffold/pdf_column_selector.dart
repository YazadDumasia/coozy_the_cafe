import 'package:flutter/material.dart';

class PdfColumnSelector extends StatelessWidget {
  final int selectedColumns;
  final ValueChanged<int> onColumnChanged;
  final List<int> allowedColumns;

  const PdfColumnSelector({
    super.key,
    required this.selectedColumns,
    required this.onColumnChanged,
    this.allowedColumns = const [2, 3, 4],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Columns:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          SegmentedButton<int>(
            segments: allowedColumns.map((cols) {
              IconData icon;
              if (cols == 2) {
                icon = Icons.view_column_outlined;
              } else if (cols == 3) {
                icon = Icons.view_week_outlined;
              } else {
                icon = Icons.grid_view_rounded;
              }
              return ButtonSegment<int>(
                value: cols,
                label: Text('$cols Cols'),
                icon: Icon(icon, size: 16),
              );
            }).toList(),
            selected: {selectedColumns},
            onSelectionChanged: (newSelection) {
              if (newSelection.isNotEmpty) {
                onColumnChanged(newSelection.first);
              }
            },
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
