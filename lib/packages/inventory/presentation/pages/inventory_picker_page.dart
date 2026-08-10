import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventory_picker_bloc/inventory_picker_bloc.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventory_picker_bloc/inventory_picker_state.dart';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'inventory_picker_page_actions.dart';
import 'widgets/inventory_picker_list_item.dart';

class InventoryPickerPage extends StatefulWidget {
  const InventoryPickerPage({super.key});

  @override
  State<InventoryPickerPage> createState() => _InventoryPickerPageState();
}

class _InventoryPickerPageState extends State<InventoryPickerPage> {
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
      () => InventoryPickerPageActions.onScroll(context, _scrollController),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
                shared.LocaleKeys.inventoryPickerPageAppbar,
                track: shared.TrackConstants.inventoryPageTrack,
              ) ??
              'Inventory Picker',
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText:
                  context.tr(
                    shared.LocaleKeys.inventoryListPageSearchHint,
                    track: shared.TrackConstants.inventoryPageTrack,
                  ) ??
                  'Search inventory...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (query) =>
                InventoryPickerPageActions.onSearchChanged(context, query),
          ),
        ),
        Expanded(
          child: BlocBuilder<InventoryPickerBloc, InventoryPickerState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                if (state.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (state.errorMessage != null) {
                  return Center(
                    child: Text(
                      '${context.tr(shared.LocaleKeys.commonError, track: shared.TrackConstants.commonTrack) ?? 'Error'}: ${state.errorMessage}',
                    ),
                  );
                }
                return Center(
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.inventoryListPageNoDataFound,
                          track: shared.TrackConstants.inventoryPageTrack,
                        ) ??
                        'No inventory items found.',
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                itemCount: state.hasReachedMax
                    ? state.items.length
                    : state.items.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index >= state.items.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final item = state.items[index];
                  return InventoryPickerListItem(item: item);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
