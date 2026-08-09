import 'dart:async';
import 'dart:ui';
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/usecases/menu_category_usecases.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_event.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_state.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/pages/widgets/menu_subcategory_grid_card.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/pages/widgets/menu_subcategory_list_item.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_subcategory_full_list_screen_actions.dart';

class MenuSubcategoryFullListScreen extends StatefulWidget {
  const MenuSubcategoryFullListScreen({super.key});

  @override
  State<MenuSubcategoryFullListScreen> createState() =>
      _MenuSubcategoryFullListScreenState();
}

class _MenuSubcategoryFullListScreenState
    extends State<MenuSubcategoryFullListScreen> {
  final SearchController _searchController = SearchController();
  final FocusNode _searchFocusNode = FocusNode();

  List<MenuCategory> _categories = [];
  int? _selectedCategoryId; // null = "All"
  bool _isGridView = false;

  final ScrollController _categorySidebarScrollController = ScrollController();
  final ScrollController _subcategoryScrollController = ScrollController();
  final Map<int, GlobalKey> _subcategoryKeys = {};

  @override
  void initState() {
    super.initState();
    _loadViewModePreference();
    _fetchCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuSubcategoryBloc>().add(const LoadMenuSubcategories());
    });
  }

  void _loadViewModePreference() {
    final bool savedIsGrid = shared.LocalManager.instance.getBoolValue(
      key: shared.PreferencesKeys.subcategoryIsGridView,
    );
    setState(() {
      _isGridView = savedIsGrid;
    });
  }

  Future<void> _toggleViewMode() async {
    final bool newMode = !_isGridView;
    setState(() {
      _isGridView = newMode;
    });
    await shared.LocalManager.instance.setBoolValue(
      key: shared.PreferencesKeys.subcategoryIsGridView,
      value: newMode,
    );
  }

  Future<void> _fetchCategories() async {
    try {
      final getCategoriesUseCase = core.sl<GetMenuCategoriesUseCase>();
      final list = await getCategoriesUseCase();
      if (mounted) {
        setState(() {
          _categories = list;
        });
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        MenuSubcategoryFullListScreen,
        'Error fetching categories: $e',
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _categorySidebarScrollController.dispose();
    _subcategoryScrollController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    context.read<MenuSubcategoryBloc>().add(
      FilterMenuSubcategoriesByCategory(categoryId),
    );
  }

  Future<void> _onRefresh() async {
    final completer = Completer<void>();
    _selectedCategoryId = null;
    context.read<MenuSubcategoryBloc>().add(
      LoadMenuSubcategories(
        onSuccess: () {
          if (!completer.isCompleted) completer.complete();
        },
        onError: (error) {
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    await _fetchCategories();
    await completer.future;
    if (mounted) setState(() {});
  }

  void _onSearchResultSelected(
    String keyword,
    List<MenuSubcategory> allSubcategories,
  ) {
    if (_searchController.isOpen) {
      _searchController.closeView(keyword);
    }

    final matchIndex = allSubcategories.indexWhere(
      (sub) => sub.name?.toLowerCase().contains(keyword.toLowerCase()) ?? false,
    );

    if (matchIndex != -1) {
      final matchedSub = allSubcategories[matchIndex];

      // Select parent category and trigger subcategories load for that category
      _onCategorySelected(matchedSub.categoryId);

      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        final targetKey = _subcategoryKeys[matchedSub.id];
        if (targetKey?.currentContext != null) {
          Scrollable.ensureVisible(
            targetKey!.currentContext!,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.menuSubCategoryAppbarTitle,
                  track: shared.TrackConstants.menuSubCategoryPageTrack,
                ) ??
                'All Subcategories',
          ),
          actions: [
            BlocBuilder<MenuSubcategoryBloc, MenuSubcategoryState>(
              builder: (context, state) {
                final bool isReordering =
                    state is MenuSubcategoryLoaded && state.isReorderAllowed;
                final bool canReorder = _selectedCategoryId != null;

                if (isReordering) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Cancel reordering',
                        onPressed: () {
                          context.read<MenuSubcategoryBloc>().add(
                            const CancelSubcategoryReorder(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.done),
                        tooltip: 'Done reordering',
                        onPressed: () {
                          context.read<MenuSubcategoryBloc>().add(
                            const SaveSubcategoryReorder(),
                          );
                        },
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canReorder)
                      IconButton(
                        icon: const Icon(Icons.swap_vert),
                        tooltip: 'Reorder mode',
                        onPressed: () {
                          context.read<MenuSubcategoryBloc>().add(
                            const ToggleSubcategoryReorderMode(),
                          );
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        _isGridView ? Icons.view_list : Icons.grid_view,
                      ),
                      tooltip: _isGridView
                          ? 'Switch to List'
                          : 'Switch to Grid',
                      onPressed: _toggleViewMode,
                    ),
                    IconButton(
                      onPressed: () =>
                          MenuSubcategoryFullListScreenActions.handleAddSubcategory(
                            context,
                            mounted,
                            onRefreshCategories: _fetchCategories,
                          ),
                      icon: const Icon(Icons.add),
                      tooltip: 'Add new subcategory',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            BlocBuilder<MenuSubcategoryBloc, MenuSubcategoryState>(
              builder: (context, state) {
                if (state is MenuSubcategoryLoaded) {
                  return _buildSearchAnchor(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySidebar(context),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(
                    child:
                        BlocConsumer<MenuSubcategoryBloc, MenuSubcategoryState>(
                          listener: (context, state) {
                            if (state is MenuSubcategoryError) {
                              core.PlatformUtils.debugLog(
                                MenuSubcategoryFullListScreen,
                                'MenuSubcategoryError:${state.message}',
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is MenuSubcategoryLoading ||
                                state is MenuSubcategoryInitial) {
                              return const shared.LoadingPage();
                            } else if (state is MenuSubcategoryLoaded) {
                              return _buildSubcategoryContent(state);
                            } else if (state is MenuSubcategoryError) {
                              return shared.ErrorPage(
                                onPressedRetryButton: () async {
                                  context.read<MenuSubcategoryBloc>().add(
                                    const LoadMenuSubcategories(),
                                  );
                                },
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAnchor(BuildContext context, MenuSubcategoryLoaded state) {
    final outerContext = context;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SearchAnchor(
        searchController: _searchController,
        isFullScreen: false,
        viewConstraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .35 < 220
              ? 220
              : MediaQuery.of(context).size.height * .35 > 220
              ? 250
              : MediaQuery.of(context).size.height * .35,
        ),
        builder: (BuildContext context, SearchController controller) {
          return Theme(
            data: Theme.of(context),
            child: SearchBar(
              controller: controller,
              focusNode: _searchFocusNode,
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 12.0),
              ),
              hintText:
                  context.tr(
                    shared.LocaleKeys.commonSearchHint,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Search subcategories...',
              leading: const Icon(Icons.search),
              onTap: () {
                controller.openView();
              },
              onChanged: (value) {
                if (!controller.isOpen) {
                  controller.openView();
                }
              },
            ),
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
              final query = controller.text.trim().toLowerCase();
              final allSubs = outerContext
                  .read<MenuSubcategoryBloc>()
                  .allSubcategories;
              final filtered = allSubs.where((sub) {
                final name = sub.name?.toLowerCase() ?? '';
                return name.contains(query);
              }).toList();

              if (filtered.isEmpty) {
                return [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No subcategories found.'),
                  ),
                ];
              }

              return filtered.map((sub) {
                final matchCat = _categories.cast<MenuCategory?>().firstWhere(
                  (c) => c?.id == sub.categoryId,
                  orElse: () => null,
                );
                final catName = matchCat?.name ?? 'Category';

                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      (sub.name != null && sub.name!.isNotEmpty)
                          ? sub.name![0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  title: Text(sub.name ?? ''),
                  subtitle: Text(catName),
                  onTap: () {
                    _onSearchResultSelected(sub.name ?? '', allSubs);
                  },
                );
              }).toList();
            },
      ),
    );
  }

  Widget _buildCategorySidebar(BuildContext context) {
    return SizedBox(
      width: 100,
      child: ListView.builder(
        key: const PageStorageKey('category_sidebar_list'),
        primary: false,
        controller: _categorySidebarScrollController,
        itemCount: _categories.length + 1, // +1 for "All" tab
        itemBuilder: (context, index) {
          final bool isAllTab = index == 0;
          final MenuCategory? category = isAllTab
              ? null
              : _categories[index - 1];
          final bool isSelected = isAllTab
              ? _selectedCategoryId == null
              : _selectedCategoryId == category?.id;

          final String title = isAllTab ? 'All' : (category?.name ?? '');

          return InkWell(
            onTap: () => _onCategorySelected(isAllTab ? null : category?.id),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    child: Text(
                      isAllTab ? 'ALL' : (title.isNotEmpty ? title[0] : '?'),
                      style: TextStyle(
                        fontSize: isAllTab ? 10 : 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoryContent(MenuSubcategoryLoaded state) {
    final displayList = List<MenuSubcategory>.from(state.subcategories);

    if (displayList.isEmpty) {
      return _buildEmptyState();
    }

    // Re-sort and re-stamp suspension flags on the filtered subset so letter headers are always correct.
    shared.SuspensionUtil.sortListBySuspensionTag(displayList);
    shared.SuspensionUtil.setShowSuspensionStatus(displayList);

    if (state.isReorderAllowed && _selectedCategoryId != null) {
      return ReorderableListView.builder(
        scrollController: _subcategoryScrollController,
        padding: const EdgeInsets.all(10),
        itemCount: displayList.length,
        buildDefaultDragHandles: false,
        onReorderItem: (oldIndex, newIndex) {
          core.PlatformUtils.debugLog(
            MenuSubcategoryFullListScreen,
            'Reordering subcategory from index $oldIndex to $newIndex',
          );
          context.read<MenuSubcategoryBloc>().add(
            ReorderMenuSubcategories(oldIndex, newIndex),
          );
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            key: UniqueKey(),
            animation: animation,
            builder: (BuildContext context, Widget? childWidget) {
              final double animValue = Curves.easeInOut.transform(
                animation.value,
              );
              final double scale = lerpDouble(1, 1.02, animValue)!;
              return Transform.scale(
                scale: scale,
                child: MenuSubcategoryListItem(
                  subCategory: displayList[index],
                  isLastItem: index == (displayList.length - 1),
                  isReorderMode: true,
                  index: index,
                ),
              );
            },
          );
        },
        itemBuilder: (context, index) {
          final item = displayList[index];
          if (item.id != null) {
            _subcategoryKeys[item.id!] ??= GlobalKey();
          }
          return Container(
            key: ValueKey(item.id ?? index),
            margin: const EdgeInsets.only(bottom: 8),
            child: MenuSubcategoryListItem(
              subCategory: item,
              isLastItem: index == (displayList.length - 1),
              isReorderMode: true,
              index: index,
            ),
          );
        },
      );
    }

    if (_isGridView) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double crossAxisExtent = 200.0;
            final int crossAxisCount = (constraints.maxWidth / crossAxisExtent)
                .floor()
                .clamp(2, 6);
            final double itemWidth =
                (constraints.maxWidth - ((crossAxisCount - 1) * 10)) /
                crossAxisCount;
            // Card height auto proportional to width (approx 160px height)
            final double childAspectRatio = itemWidth / 180.0;

            return GridView.builder(
              key: PageStorageKey(
                'subcategory_grid_${_selectedCategoryId ?? 0}',
              ),
              controller: _subcategoryScrollController,
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final item = displayList[index];
                return Container(
                  key: ValueKey('grid_${item.id}_${item.isActive}'),
                  child: MenuSubcategoryGridCard(subCategory: item),
                );
              },
            );
          },
        ),
      );
    }

    final bool isSearchActive = state.isSearchActive;
    // Sidebar index bar only when viewing all subcategories and not searching.
    // Letter-group headers (susItemBuilder) always appear.
    final bool showIndexBar = _selectedCategoryId == null && !isSearchActive;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: shared.AzListView(
        key: ValueKey(
          'subcategory_list_${_selectedCategoryId ?? 'all'}_${displayList.map((e) => '${e.id}:${e.isActive}').join('_')}',
        ),
        data: displayList,
        itemCount: displayList.length,
        physics: const AlwaysScrollableScrollPhysics(),
        susItemHeight: 46,
        indexBarData: showIndexBar
            ? shared.kIndexBarData
                  .where(
                    (tag) =>
                        displayList.any((e) => e.getSuspensionTag() == tag),
                  )
                  .toList()
            : const [],
        indexBarOptions: shared.IndexBarOptions(
          needRebuild: true,
          selectItemDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          selectTextStyle: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          indexHintWidth: 64,
          indexHintHeight: 64,
          indexHintDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary
                // ignore: deprecated_member_use
                .withOpacity(0.92),
            shape: BoxShape.circle,
          ),
          indexHintTextStyle: TextStyle(
            fontSize: 28.0,
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          indexHintAlignment: Alignment.centerRight,
          indexHintOffset: const Offset(-40, 0),
        ),
        itemBuilder: (context, index) {
          final item = displayList[index];
          final isLastItem = index == displayList.length - 1;
          return Container(
            key: ValueKey('list_${item.id}_${item.isActive}'),
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: isLastItem ? 10 : 0,
            ),
            child: MenuSubcategoryListItem(
              subCategory: item,
              isLastItem: isLastItem,
            ),
          );
        },
        susItemBuilder: (context, index) {
          final tag = displayList[index].getSuspensionTag();
          return Container(
            height: 36,
            width: double.infinity,
            margin: EdgeInsets.only(top: index == 0 ? 0 : 10),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.centerLeft,
            child: Text(
              tag,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No subcategories found.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () =>
                MenuSubcategoryFullListScreenActions.handleAddSubcategory(
                  context,
                  mounted,
                  categoryId: _selectedCategoryId,
                  onRefreshCategories: _fetchCategories,
                ),
            icon: const Icon(Icons.add),
            label: const Text('Add Subcategory'),
          ),
        ],
      ),
    );
  }
}
