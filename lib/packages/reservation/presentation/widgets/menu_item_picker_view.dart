import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../domain/entities/reservation_entity.dart';

class MenuItemPickerView extends StatefulWidget {
  final List<PreOrderedMenuItemEntity> selectedItems;
  final ValueChanged<List<PreOrderedMenuItemEntity>> onItemsChanged;

  const MenuItemPickerView({
    super.key,
    required this.selectedItems,
    required this.onItemsChanged,
  });

  static Future<void> showSearchDialog(
    BuildContext context, {
    required List<PreOrderedMenuItemEntity> selectedItems,
    required ValueChanged<List<PreOrderedMenuItemEntity>> onItemsChanged,
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
                      context.tr(
                            shared.LocaleKeys.searchMenuItemsTitle,
                            track: shared.TrackConstants.reservationPageTrack,
                          ) ??
                          'Search & Pre-order Menu Items',
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
                  child: MenuItemPickerView(
                    key: const ValueKey('dialog_menu_item_picker'),
                    selectedItems: selectedItems,
                    onItemsChanged: onItemsChanged,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.commonDone,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Done',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  State<MenuItemPickerView> createState() => _MenuItemPickerViewState();
}

class _MenuItemPickerViewState extends State<MenuItemPickerView> {
  final ValueNotifier<List<MenuItem>> _allItemsNotifier = ValueNotifier([]);
  final ValueNotifier<List<MenuItem>> _filteredItemsNotifier = ValueNotifier(
    [],
  );
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  @override
  void dispose() {
    _allItemsNotifier.dispose();
    _filteredItemsNotifier.dispose();
    _isLoadingNotifier.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuItems() async {
    try {
      final db = sl<CoozyDatabase>();
      final list = await db.select(db.menuItemsTable).get();
      if (mounted) {
        _allItemsNotifier.value = list;
        _filteredItemsNotifier.value = list;
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
      _filteredItemsNotifier.value = _allItemsNotifier.value;
    } else {
      _filteredItemsNotifier.value = _allItemsNotifier.value.where((item) {
        final name = item.name.toLowerCase();
        final desc = item.description.toLowerCase();
        final code = (item.quantity ?? '').toLowerCase();
        return name.contains(q) || desc.contains(q) || code.contains(q);
      }).toList();
    }
  }

  void _updateQuantity(MenuItem item, int delta) {
    final currentList = List<PreOrderedMenuItemEntity>.from(
      widget.selectedItems,
    );
    final index = currentList.indexWhere((e) => e.itemId == item.id);

    if (index >= 0) {
      final existing = currentList[index];
      final newQty = existing.quantity + delta;
      if (newQty <= 0) {
        currentList.removeAt(index);
      } else {
        currentList[index] = existing.copyWith(quantity: newQty);
      }
    } else if (delta > 0) {
      currentList.add(
        PreOrderedMenuItemEntity(
          itemId: item.id,
          itemName: item.name,
          quantity: 1,
          price: item.sellingPrice ?? 0.0,
        ),
      );
    }
    widget.onItemsChanged(currentList);
  }

  @override
  void didUpdateWidget(covariant MenuItemPickerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItems != widget.selectedItems) {
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
          children: [
            TextField(
              controller: _searchController,
              onChanged: (val) {
                _onSearch(val);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText:
                    context.tr(
                      shared.LocaleKeys.searchMenuItemHint,
                      track: shared.TrackConstants.reservationPageTrack,
                    ) ??
                    'Search menu items...',
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
                child: ValueListenableBuilder<List<MenuItem>>(
                  valueListenable: _filteredItemsNotifier,
                  builder: (context, filteredItems, child) {
                    if (_allItemsNotifier.value.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 36,
                                color: hintColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No menu items available.',
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

                    if (filteredItems.isEmpty) {
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
                                'No matching menu items found.',
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
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final selected = widget.selectedItems.firstWhere(
                          (e) => e.itemId == item.id,
                          orElse: () => const PreOrderedMenuItemEntity(
                            itemId: 0,
                            itemName: '',
                            quantity: 0,
                            price: 0,
                          ),
                        );
                        final qty = selected.quantity;

                        return ListTile(
                          dense: true,
                          title: Text(item.name),
                          subtitle: Text(
                            (item.sellingPrice ?? 0.0).toStringAsFixed(2),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (qty > 0) ...[
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 20,
                                  ),
                                  onPressed: () => _updateQuantity(item, -1),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                ),
                                onPressed: () => _updateQuantity(item, 1),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            if (widget.selectedItems.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Items: ${widget.selectedItems.fold(0, (sum, i) => sum + i.quantity)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Pre-order Total: ${widget.selectedItems.fold(0.0, (sum, i) => sum + (i.price * i.quantity)).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
