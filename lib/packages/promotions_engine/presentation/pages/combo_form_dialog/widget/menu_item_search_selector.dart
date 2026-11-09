import 'dart:async';

import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item_variation.dart';

import '../../../../domain/usecases/combo_usecases.dart';

class MenuItemSearchSelector extends StatefulWidget {
  final SearchMenuItemsForComboUseCase searchUseCase;
  final GetMenuItemsCountForComboUseCase countUseCase;
  final Function(MenuItem item, MenuItemVariation? variation) onItemSelected;

  const MenuItemSearchSelector({
    super.key,
    required this.searchUseCase,
    required this.countUseCase,
    required this.onItemSelected,
  });

  @override
  State<MenuItemSearchSelector> createState() => _MenuItemSearchSelectorState();
}

class _MenuItemSearchSelectorState extends State<MenuItemSearchSelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  final ValueNotifier<List<MenuItem>> _itemsNotifier =
      ValueNotifier<List<MenuItem>>([]);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> _totalCountNotifier = ValueNotifier<int>(0);
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _itemsNotifier.dispose();
    _isLoadingNotifier.dispose();
    _currentPageNotifier.dispose();
    _totalCountNotifier.dispose();
    super.dispose();
  }

  Future<void> _fetchMenuItems() async {
    final query = _searchController.text.trim();
    final page = _currentPageNotifier.value;
    final offset = (page - 1) * _pageSize;

    PlatformUtils.debugLog(
      MenuItemSearchSelector,
      '_fetchMenuItems: query="$query", page=$page, pageSize=$_pageSize, offset=$offset',
    );

    _isLoadingNotifier.value = true;

    final countRes = await widget.countUseCase(searchQuery: query);
    countRes.fold(
      (failure) {
        PlatformUtils.debugLog(
          MenuItemSearchSelector,
          '_fetchMenuItems: count error: ${failure.message}',
        );
        _totalCountNotifier.value = 0;
      },
      (count) {
        PlatformUtils.debugLog(
          MenuItemSearchSelector,
          '_fetchMenuItems: total items count=$count',
        );
        _totalCountNotifier.value = count;
      },
    );

    final res = await widget.searchUseCase(
      searchQuery: query,
      limit: _pageSize,
      offset: offset,
    );

    if (mounted) {
      res.fold(
        (failure) {
          PlatformUtils.debugLog(
            MenuItemSearchSelector,
            '_fetchMenuItems: search error: ${failure.message}',
          );
          _itemsNotifier.value = [];
          _isLoadingNotifier.value = false;
        },
        (items) {
          PlatformUtils.debugLog(
            MenuItemSearchSelector,
            '_fetchMenuItems: retrieved ${items.length} items successfully',
          );
          _itemsNotifier.value = items;
          _isLoadingNotifier.value = false;
        },
      );
    }
  }

  void _onSearchChanged(String val) {
    PlatformUtils.debugLog(
      MenuItemSearchSelector,
      '_onSearchChanged: typed "$val", scheduling 300ms debounce',
    );
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _currentPageNotifier.value = 1;
      _fetchMenuItems();
    });
  }

  int _totalPages(int totalCount) => (totalCount / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search menu items by name...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isLoadingNotifier,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ValueListenableBuilder<List<MenuItem>>(
                  valueListenable: _itemsNotifier,
                  builder: (context, items, _) {
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No menu items found.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: items.length,
                      addRepaintBoundaries: true,
                      addAutomaticKeepAlives: false,
                      separatorBuilder: (_, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final hasVariations = item.variations.isNotEmpty;

                        if (hasVariations) {
                          return ExpansionTile(
                            dense: true,
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${item.variations.length} variations available',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            children: item.variations.map((v) {
                              final vDur = v.duration ?? item.duration;
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                title: Text(v.name ?? 'Variation'),
                                subtitle: (vDur != null && vDur > 0)
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$vDur mins prep',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      v.sellingPrice != null
                                          ? CurrencyFormatter.format(
                                              value: v.sellingPrice!,
                                            )
                                          : '0.00',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filledTonal(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: () =>
                                          widget.onItemSelected(item, v),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }

                        return ListTile(
                          dense: true,
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.sellingPrice != null
                                    ? CurrencyFormatter.format(
                                        value: item.sellingPrice!,
                                      )
                                    : '0.00',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item.duration != null &&
                                  item.duration! > 0) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.timer_outlined,
                                  size: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.duration} mins',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton.filledTonal(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => widget.onItemSelected(item, null),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Pagination controls
          ValueListenableBuilder<int>(
            valueListenable: _totalCountNotifier,
            builder: (context, totalCount, _) {
              final totalPages = _totalPages(totalCount);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: $totalCount items',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _currentPageNotifier,
                    builder: (context, currentPage, _) {
                      return Row(
                        children: [
                          IconButton(
                            iconSize: 20,
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: currentPage > 1
                                ? () {
                                    _currentPageNotifier.value =
                                        currentPage - 1;
                                    _fetchMenuItems();
                                  }
                                : null,
                          ),
                          Text(
                            '$currentPage / ${totalPages > 0 ? totalPages : 1}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            iconSize: 20,
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: currentPage < totalPages
                                ? () {
                                    _currentPageNotifier.value =
                                        currentPage + 1;
                                    _fetchMenuItems();
                                  }
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
