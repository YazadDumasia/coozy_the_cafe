import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widget/menu_item_search_screen.dart';

/// Mixin handling search inputs, category tabs, and controllers for waiter menu item selection.
mixin MenuItemPickerScreenActions<T extends StatefulWidget> on State<T> {
  /// Controller for menu search input.
  late TextEditingController searchController;

  /// Focus node managing keyboard focus for the search input.
  late FocusNode searchFocusNode;

  /// Indicates whether the search interface is currently active.
  bool isSearchMode = false;

  /// Initializes text editing controllers and wires search query listeners.
  void initActions() {
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
    searchController.addListener(_onSearchChanged);
  }

  /// Dispatches search filtering events to [MenuItemPickerBloc] as the user types.
  void _onSearchChanged() {
    if (mounted) {
      context.read<MenuItemPickerBloc>().add(
        FilterSearchQueryEvent(searchController.text.trim()),
      );
    }
  }

  /// Toggles between category navigation mode and search filter mode.
  void toggleSearchMode() {
    setState(() {
      isSearchMode = !isSearchMode;
      if (!isSearchMode) {
        searchController.clear();
        searchFocusNode.unfocus();
        context.read<MenuItemPickerBloc>().add(
          const FilterSearchQueryEvent(''),
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            searchFocusNode.requestFocus();
          }
        });
      }
    });
  }

  /// Opens the dedicated full-screen menu item search dialog.
  void openSearchScreen(BuildContext context) {
    MenuItemSearchScreen.push(context);
  }

  /// Animates tab selection and notifies BLoC to switch displayed category.
  void onTabSelected(TabController tabController, int index) {
    tabController.animateTo(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
    context.read<MenuItemPickerBloc>().add(SelectCategoryTabEvent(index));
  }

  /// Cleans up listeners and disposes text controllers and focus nodes.
  void disposeActions() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    searchFocusNode.dispose();
  }
}
