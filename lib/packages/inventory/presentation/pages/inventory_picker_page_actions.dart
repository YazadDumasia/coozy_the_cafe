import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventory_picker_bloc.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventory_picker_event.dart';

class InventoryPickerPageActions {
  static void onScroll(
    BuildContext context,
    ScrollController scrollController,
  ) {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      context.read<InventoryPickerBloc>().add(const LoadInventoryPickerItems());
    }
  }

  static void onSearchChanged(BuildContext context, String query) {
    context.read<InventoryPickerBloc>().add(
      LoadInventoryPickerItems(isRefresh: true, searchQuery: query),
    );
  }
}
