import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/menu_item_picker_bloc.dart';
import 'menu_item_picker_screen_actions.dart';
import 'widget/category_dropdown_app_bar_title.dart';
import 'widget/category_menu_items_tab_view.dart';
import 'widget/current_order_tab_view.dart';

class MenuItemPickerScreen extends StatefulWidget {
  final TableEntity? table;
  final int? tableId;
  final String? tableName;

  const MenuItemPickerScreen({
    super.key,
    this.table,
    this.tableId,
    this.tableName,
  });

  @override
  State<MenuItemPickerScreen> createState() => _MenuItemPickerScreenState();
}

class _MenuItemPickerScreenState extends State<MenuItemPickerScreen>
    with
        TickerProviderStateMixin,
        MenuItemPickerScreenActions<MenuItemPickerScreen> {
  TabController? _tabController;
  int _tabCount = 0;

  int get effectiveTableId => widget.table?.id ?? widget.tableId ?? 1;
  String get effectiveTableName {
    if (widget.table != null) {
      return (widget.table!.tableNumber != null &&
              widget.table!.tableNumber!.isNotEmpty)
          ? widget.table!.tableNumber!
          : widget.table!.name;
    }
    return widget.tableName ?? 'Table';
  }

  @override
  void initState() {
    super.initState();
    initActions();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    disposeActions();
    super.dispose();
  }

  void _syncTabController(int requiredCount) {
    if (_tabController == null || _tabCount != requiredCount) {
      _tabController?.dispose();
      _tabCount = requiredCount;
      _tabController = TabController(length: _tabCount, vsync: this);
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          context.read<MenuItemPickerBloc>().add(
            SelectCategoryTabEvent(_tabController!.index),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MenuItemPickerBloc, MenuItemPickerState>(
      listener: (context, state) {
        if (state is MenuItemPickerLoadedState) {
          if (state.orderSuccessMessage != null &&
              state.orderSuccessMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.orderSuccessMessage!),
                backgroundColor: Colors.green,
              ),
            );
            context.go(core.AppRoutePath.homeRoute);
          } else if (state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (_tabController != null &&
              state.selectedTabIndex < _tabController!.length &&
              _tabController!.index != state.selectedTabIndex) {
            _tabController!.animateTo(state.selectedTabIndex);
          }
        }
      },
      builder: (context, state) {
        if (state is MenuItemPickerLoadingState ||
            state is MenuItemPickerInitialState) {
          return const SafeArea(child: Scaffold(body: shared.LoadingPage()));
        }

        if (state is MenuItemPickerErrorState) {
          return SafeArea(
            child: Scaffold(
              body: shared.ErrorPage(
                onPressedRetryButton: () {
                  context.read<MenuItemPickerBloc>().add(
                    const LoadMenuCatalogEvent(),
                  );
                },
              ),
            ),
          );
        }

        if (state is! MenuItemPickerLoadedState) {
          return const SizedBox.shrink();
        }

        final catalogData = state.catalogData;
        final categories = catalogData.activeCategories;
        final totalTabs = categories.length + 1; // Tab 0 = Current Order

        _syncTabController(totalTabs);

        final theme = Theme.of(context);
        final appBarFgColor =
            theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && context.mounted) {
              context.go(core.AppRoutePath.homeRoute);
            }
          },
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(core.AppRoutePath.homeRoute),
                ),
              title: isSearchMode
                  ? TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search dish name...',
                        border: InputBorder.none,
                      ),
                      style: theme.textTheme.titleMedium,
                    )
                  : CategoryDropdownAppBarTitle(
                      categories: categories,
                      selectedTabIndex: state.selectedTabIndex,
                      onCategorySelected: (index) {
                        onTabSelected(_tabController!, index);
                      },
                    ),
              actions: [
                // Fast Forward / Order Summary Action Button (>> icon)
                IconButton(
                  tooltip: 'Current Order',
                  icon: Icon(
                    Icons.fast_forward_rounded,
                    color: appBarFgColor,
                    size: 26,
                  ),
                  onPressed: () {
                    onTabSelected(_tabController!, 0);
                  },
                ),

                // Search Action Button
                IconButton(
                  tooltip: 'Search',
                  icon: Icon(isSearchMode ? Icons.close : Icons.search),
                  onPressed: toggleSearchMode,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: appBarFgColor,
                unselectedLabelColor: appBarFgColor.withValues(alpha: 0.7),
                indicatorColor: appBarFgColor,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  color: appBarFgColor.withValues(alpha: 0.7),
                ),
                tabs: [
                  const Tab(text: 'CURRENT ORDER'),
                  for (final cat in categories)
                    Tab(text: (cat.name ?? '').toUpperCase()),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Current Order Tab
                CurrentOrderTabView(
                  cartItems: state.cartItems,
                  tableId: effectiveTableId,
                  tableName: effectiveTableName,
                  isSubmitting: state.isSubmitting,
                ),

                // Tab 1..N: Category Tabs
                for (int i = 0; i < categories.length; i++)
                  CategoryMenuItemsTabView(
                    categoryData: catalogData.categoryDataList[i],
                    searchQuery: state.searchQuery,
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
  }
}
