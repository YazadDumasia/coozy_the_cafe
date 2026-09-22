import 'package:flutter/material.dart';

class ReportDataTable extends StatelessWidget {
  const ReportDataTable({super.key, required this.headers, required this.rows});

  final List<String> headers;
  final List<List<dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (rows.isEmpty) {
      return Center(
        child: Text(
          'No tabular records to display',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    ),
                    headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                    horizontalMargin: 16,
                    columnSpacing: 24,
                    columns: headers
                        .map(
                          (h) => DataColumn(
                            label: Text(
                              h,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    rows: rows.map((row) {
                      return DataRow(
                        cells: row
                            .map(
                              (cell) => DataCell(
                                Text(
                                  cell is double
                                      ? cell.toStringAsFixed(2)
                                      : (cell?.toString() ?? '—'),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
