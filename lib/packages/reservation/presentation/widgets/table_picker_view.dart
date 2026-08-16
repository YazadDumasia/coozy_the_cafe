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
        final name = (t.name ?? '').toLowerCase();
        return name.contains(q);
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
          name: item.name,
          colorValue: item.colorValue,
          sortOrderIndex: item.sortOrderIndex,
          nosOfChairs: item.nosOfChairs,
        ),
      );
    }
    widget.onTablesChanged(currentList);
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search tables...',
                prefixIcon: const Icon(Icons.search, size: 20),
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
                    if (filteredTables.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('No matching tables.')),
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
                          title: Text(item.name ?? 'Table ${item.id}'),
                          subtitle: Text('${item.nosOfChairs ?? 0} Chairs'),
                          secondary: CircleAvatar(
                            radius: 12,
                            backgroundColor: item.colorValue != null
                                ? Color(
                                    int.parse(
                                      item.colorValue!.replaceAll('#', '0xff'),
                                    ),
                                  )
                                : Theme.of(context).colorScheme.primary,
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
