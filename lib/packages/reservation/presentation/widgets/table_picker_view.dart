import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_info.dart';

class TablePickerView extends StatefulWidget {
  final List<TableInfo> selectedTables;
  final ValueChanged<List<TableInfo>> onTablesChanged;

  const TablePickerView({
    super.key,
    required this.selectedTables,
    required this.onTablesChanged,
  });

  static Future<void> showSearchDialog(
    BuildContext context, {
    required List<TableInfo> selectedTables,
    required ValueChanged<List<TableInfo>> onTablesChanged,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search & Select Tables',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: TablePickerView(
                    key: const ValueKey('dialog_table_picker'),
                    selectedTables: selectedTables,
                    onTablesChanged: onTablesChanged,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  State<TablePickerView> createState() => _TablePickerViewState();
}

class _TablePickerViewState extends State<TablePickerView> {
  final ValueNotifier<List<TableInfoData>> _allTablesNotifier = ValueNotifier(
    [],
  );
  final ValueNotifier<List<TableInfoData>> _filteredTablesNotifier =
      ValueNotifier([]);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  @override
  void dispose() {
    _allTablesNotifier.dispose();
    _filteredTablesNotifier.dispose();
    _isLoadingNotifier.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    try {
      final db = sl<CoozyDatabase>();
      final list = await db.select(db.tableInfoTable).get();
      if (mounted) {
        _allTablesNotifier.value = list;
        _filteredTablesNotifier.value = list;
        _isLoadingNotifier.value = false;
      }
    } catch (_) {
      if (mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredTablesNotifier.value = _allTablesNotifier.value;
    } else {
      _filteredTablesNotifier.value = _allTablesNotifier.value.where((t) {
        final label = (t.tableLabel ?? '').toLowerCase();
        final no = (t.tableNo ?? '').toLowerCase();
        return label.contains(q) || no.contains(q);
      }).toList();
    }
  }

  void _toggleSelection(TableInfoData item) {
    final currentList = List<TableInfo>.from(widget.selectedTables);
    final index = currentList.indexWhere((t) => t.id == item.id);

    if (index >= 0) {
      currentList.removeAt(index);
    } else {
      currentList.add(
        TableInfo(
          id: item.id,
          tableLabel: item.tableLabel,
          tableNo: item.tableNo,
          colorValue: item.colorValue,
          sortOrderIndex: item.sortOrderIndex,
          nosOfChairs: item.nosOfChairs,
        ),
      );
    }
    widget.onTablesChanged(currentList);
  }

  Color _parseTableColor(BuildContext context, String? colorValue) {
    if (colorValue == null || colorValue.trim().isEmpty) {
      return Theme.of(context).colorScheme.primary;
    }
    final clean = colorValue.trim().replaceAll('#', '');
    final parsed = int.tryParse(clean) ?? int.tryParse(clean, radix: 16);
    if (parsed != null) {
      return Color(parsed | 0xFF000000);
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  void didUpdateWidget(covariant TablePickerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTables != widget.selectedTables) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final hintColor = Theme.of(context).hintColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (val) {
                _onSearch(val);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search tables...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: ValueListenableBuilder<List<TableInfoData>>(
                  valueListenable: _filteredTablesNotifier,
                  builder: (context, filteredTables, child) {
                    if (_allTablesNotifier.value.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.table_restaurant,
                                size: 36,
                                color: hintColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No Tables inserted',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (filteredTables.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 36,
                                color: hintColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No matching tables found.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredTables.length,
                      itemBuilder: (context, index) {
                        final item = filteredTables[index];
                        final isSelected = widget.selectedTables.any(
                          (t) => t.id == item.id,
                        );

                        return CheckboxListTile(
                          dense: true,
                          value: isSelected,
                          selected: isSelected,
                          activeColor: Theme.of(context).colorScheme.primary,
                          title: Text(
                            item.tableLabel ??
                                item.tableNo ??
                                'Table ${item.id}',
                          ),
                          subtitle: Text('${item.nosOfChairs ?? 0} Chairs'),
                          secondary: CircleAvatar(
                            radius: 12,
                            backgroundColor: _parseTableColor(
                              context,
                              item.colorValue,
                            ),
                          ),
                          onChanged: (_) => _toggleSelection(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
