import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin MenuItemPickerScreenActions<T extends StatefulWidget> on State<T> {
  late TextEditingController searchController;
  late FocusNode searchFocusNode;
  bool isSearchMode = false;

  void initActions() {
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (mounted) {
      context.read<MenuItemPickerBloc>().add(
        FilterSearchQueryEvent(searchController.text.trim()),
      );
    }
  }

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
        searchFocusNode.requestFocus();
      }
    });
  }

  void onTabSelected(TabController tabController, int index) {
    tabController.animateTo(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
    context.read<MenuItemPickerBloc>().add(SelectCategoryTabEvent(index));
  }

  void disposeActions() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    searchFocusNode.dispose();
  }
}
