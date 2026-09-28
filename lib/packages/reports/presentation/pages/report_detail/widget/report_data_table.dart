import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../../domain/utils/report_date_utils.dart';

class ReportDataTable extends StatefulWidget {
  const ReportDataTable({
    super.key,
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<dynamic>> rows;

  @override
  State<ReportDataTable> createState() => _ReportDataTableState();
}

class _ReportDataTableState extends State<ReportDataTable> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ValueNotifier<String> _queryNotifier;
  late final ValueNotifier<int?> _sortColumnIndexNotifier;
  late final ValueNotifier<bool> _sortAscendingNotifier;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _queryNotifier = ValueNotifier<String>('');
    _sortColumnIndexNotifier = ValueNotifier<int?>(null);
    _sortAscendingNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _queryNotifier.dispose();
    _sortColumnIndexNotifier.dispose();
    _sortAscendingNotifier.dispose();
    super.dispose();
  }

  bool _isColumnNumeric(int colIndex) {
    if (widget.rows.isEmpty) return false;
    for (final row in widget.rows) {
      if (colIndex < row.length) {
        final val = row[colIndex];
        if (val == null) continue;
        if (val is num) return true;
        // Do not treat date or period strings as numeric columns
        if (ReportDateUtils.parsePeriodDate(val) != null) return false;
        final cleanStr =
            val.toString().replaceAll('%', '').replaceAll(',', '').trim();
        if (double.tryParse(cleanStr) != null) return true;
      }
    }
    return false;
  }

  List<List<dynamic>> _processRows(
    String query,
    int? sortIndex,
    bool ascending,
  ) {
    List<List<dynamic>> result = widget.rows;
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((row) {
        return row.any(
          (cell) => cell?.toString().toLowerCase().contains(q) ?? false,
        );
      }).toList();
    } else {
      result = List.from(result);
    }

    if (sortIndex != null &&
        sortIndex >= 0 &&
        sortIndex < widget.headers.length) {
      result.sort((a, b) {
        final valA = sortIndex < a.length ? a[sortIndex] : null;
        final valB = sortIndex < b.length ? b[sortIndex] : null;

        if (valA == null && valB == null) return 0;
        if (valA == null) return ascending ? -1 : 1;
        if (valB == null) return ascending ? 1 : -1;

        if (valA is num && valB is num) {
          final cmp = valA.compareTo(valB);
          return ascending ? cmp : -cmp;
        }

        final strA = valA.toString().trim();
        final strB = valB.toString().trim();

        if (strA == '—' && strB != '—') return ascending ? -1 : 1;
        if (strB == '—' && strA != '—') return ascending ? 1 : -1;

        // 1. Chronological date/period parsing (Daily, Weekly, Monthly, Yearly, ISO)
        final dateA = ReportDateUtils.parsePeriodDate(valA);
        final dateB = ReportDateUtils.parsePeriodDate(valB);
        if (dateA != null && dateB != null) {
          final cmp = dateA.compareTo(dateB);
          if (cmp != 0) {
            return ascending ? cmp : -cmp;
          }
          // Tie-breaker for identical dates: compare full row content
          return a.join('|').compareTo(b.join('|'));
        }

        // 2. Direct numeric comparison if both are num
        if (valA is num && valB is num) {
          final cmp = valA.compareTo(valB);
          return ascending ? cmp : -cmp;
        }

        // 3. String numeric parsing (percentages, currencies, formatted numbers)
        final cleanA = strA.replaceAll('%', '').replaceAll(',', '').trim();
        final cleanB = strB.replaceAll('%', '').replaceAll(',', '').trim();

        final numA = num.tryParse(cleanA);
        final numB = num.tryParse(cleanB);

        if (numA != null && numB != null) {
          final cmp = numA.compareTo(numB);
          return ascending ? cmp : -cmp;
        }

        // 4. Default case-insensitive alphabetical comparison
        final cmp = strA.toLowerCase().compareTo(strB.toLowerCase());
        return ascending ? cmp : -cmp;
      });
    }

    return result;
  }

  Widget _buildFilterAndSortBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    int totalCount,
    int filteredCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 550;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // Search Input with Search Icon
              isWide
                  ? SizedBox(
                      width: 280,
                      child: _buildSearchBox(context, theme, scheme),
                    )
                  : Expanded(
                      child: _buildSearchBox(context, theme, scheme),
                    ),
              if (isWide) const Spacer() else const SizedBox(width: 8),
              // Active Sort Chip (shown only when a column is sorted)
              ValueListenableBuilder<int?>(
                valueListenable: _sortColumnIndexNotifier,
                builder: (context, sortIndex, _) {
                  if (sortIndex == null) return const SizedBox.shrink();
                  return ValueListenableBuilder<bool>(
                    valueListenable: _sortAscendingNotifier,
                    builder: (context, ascending, _) {
                      final colName = sortIndex < widget.headers.length
                          ? widget.headers[sortIndex]
                          : '';
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(
                              alpha: 0.35,
                            ),
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () {
                                  _sortAscendingNotifier.value = !ascending;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        ascending
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        size: 16,
                                        color: scheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        colName,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: scheme.onSurface,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Tooltip(
                                message: 'Clear sort',
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    _sortColumnIndexNotifier.value = null;
                                    _sortAscendingNotifier.value = true;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: scheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // Row Count Badge
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.format_list_numbered_rounded,
                      size: 15,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filteredCount == totalCount
                          ? '$totalCount rows'
                          : '$filteredCount / $totalCount rows',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBox(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: context.tr(
                shared.LocaleKeys.commonSearchHint,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Search...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.45),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: scheme.primary,
          ),
          suffixIcon: ValueListenableBuilder<String>(
            valueListenable: _queryNotifier,
            builder: (context, query, _) {
              if (query.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  _queryNotifier.value = '';
                },
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
        onChanged: (val) => _queryNotifier.value = val,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (widget.rows.isEmpty) {
      return Center(
        child: Text(
          context.tr(
                shared.LocaleKeys.reportPageEmptyData,
                track: shared.TrackConstants.reportPageTrack,
              ) ??
              'No data found for the selected range',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ValueListenableBuilder<String>(
      valueListenable: _queryNotifier,
      builder: (context, query, _) {
        return ValueListenableBuilder<int?>(
          valueListenable: _sortColumnIndexNotifier,
          builder: (context, sortIndex, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _sortAscendingNotifier,
              builder: (context, ascending, _) {
                final processedRows = _processRows(
                  query,
                  sortIndex,
                  ascending,
                );

                return Column(
                  children: [
                    _buildFilterAndSortBar(
                      context,
                      theme,
                      scheme,
                      widget.rows.length,
                      processedRows.length,
                    ),
                    Expanded(
                      child: processedRows.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    context.tr(
                                          shared.LocaleKeys
                                              .commonNoSearchResultFoundMsg,
                                          track:
                                              shared.TrackConstants.commonTrack,
                                        ) ??
                                        'No records matching "$query"',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 16,
                                    ),
                                    label: Text(
                                      context.tr(
                                            shared.LocaleKeys.commonClear,
                                            track: shared
                                                .TrackConstants
                                                .commonTrack,
                                          ) ??
                                          'Clear Search',
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _queryNotifier.value = '';
                                    },
                                  ),
                                ],
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    16,
                                  ),
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth - 32,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: scheme.outlineVariant
                                                  .withValues(alpha: 0.5),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: DataTable(
                                            sortColumnIndex: sortIndex,
                                            sortAscending: ascending,
                                            headingRowColor:
                                                WidgetStateProperty.all(
                                              scheme
                                                  .surfaceContainerHighest
                                                  .withValues(alpha: 0.6),
                                            ),
                                            headingTextStyle: theme
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: scheme.onSurface,
                                                ),
                                            dataTextStyle: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: scheme.onSurface,
                                                ),
                                            horizontalMargin: 16,
                                            columnSpacing: 24,
                                            columns: widget.headers
                                                .asMap()
                                                .entries
                                                .map(
                                                  (entry) {
                                                    final index = entry.key;
                                                    final header = entry.value;
                                                    final isSorted =
                                                        sortIndex == index;
                                                    final isNumeric =
                                                        _isColumnNumeric(index);

                                                    return DataColumn(
                                                      numeric: isNumeric,
                                                      tooltip:
                                                          'Sort by $header',
                                                      label: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            header,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          if (!isSorted)
                                                            Icon(
                                                              Icons
                                                                  .unfold_more_rounded,
                                                              size: 16,
                                                              color: scheme
                                                                  .onSurface
                                                                  .withValues(
                                                                    alpha: 0.35,
                                                                  ),
                                                            ),
                                                        ],
                                                      ),
                                                      onSort: (
                                                        columnIndex,
                                                        asc,
                                                      ) {
                                                        _sortColumnIndexNotifier
                                                                .value =
                                                            columnIndex;
                                                        _sortAscendingNotifier
                                                                .value = asc;
                                                      },
                                                    );
                                                  },
                                                )
                                                .toList(),
                                            rows: processedRows.map((row) {
                                              return DataRow(
                                                cells: row
                                                    .map(
                                                      (cell) => DataCell(
                                                        Text(
                                                          cell is double
                                                              ? cell
                                                                  .toStringAsFixed(
                                                                      2)
                                                              : (cell?.toString() ??
                                                                  '—'),
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
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
