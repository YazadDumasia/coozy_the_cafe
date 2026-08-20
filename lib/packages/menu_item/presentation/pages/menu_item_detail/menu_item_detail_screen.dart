import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import '../../../domain/entities/menu_item.dart';
import '../../bloc/menu_item_bloc.dart';
import 'menu_item_detail_actions.dart';
import 'widget/menu_item_detail_header_card.dart';
import 'widget/menu_item_detail_metadata_card.dart';
import 'widget/menu_item_detail_pricing_card.dart';

class MenuItemDetailScreen extends StatefulWidget {
  final int itemId;

  const MenuItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<MenuItemDetailScreen> createState() => _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends State<MenuItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<MenuItemBloc>();
    if (!bloc.isClosed && bloc.state is MenuItemInitial) {
      bloc.add(LoadMenuItems());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuItemBloc, MenuItemState>(
      builder: (context, state) {
        switch (state) {
          case MenuItemInitial():
          case MenuItemLoading():
            return const Scaffold(body: shared.LoadingPage());
          case MenuItemError():
            return Scaffold(
              appBar: AppBar(),
              body: shared.ErrorPage(
                onPressedRetryButton: () {
                  final bloc = context.read<MenuItemBloc>();
                  if (!bloc.isClosed) {
                    bloc.add(LoadMenuItems());
                  }
                },
              ),
            );
          case MenuItemLoaded():
            final item = state.items.cast<MenuItem?>().firstWhere(
                  (element) => element?.id == widget.itemId,
                  orElse: () => null,
                );

            if (item == null) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    context.tr(
                          shared.LocaleKeys.homeDrawerMenuItemLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Menu Item',
                  ),
                ),
                body: Center(
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.commonNoDataFoundMsg,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Menu item not found.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              );
            }

            return _buildDetailContent(context, item);
        }
      },
    );
  }

  Widget _buildDetailContent(BuildContext context, MenuItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String? categoryName;
    String? subcategoryName;

    final catState = context.watch<MenuCategoryFullListCubit>().state;
    if (catState is MenuCategoryFullListLoadedState) {
      final categories =
          context.read<MenuCategoryFullListCubit>().categoryList ?? [];
      for (final c in categories) {
        if (c.id == item.categoryId) {
          categoryName = c.name;
          break;
        }
      }
    }

    final subState = context.watch<MenuSubcategoryBloc>().state;
    if (subState is MenuSubcategoryLoaded) {
      for (final s in subState.subcategories) {
        if (s.id == item.subcategoryId) {
          subcategoryName = s.name;
          break;
        }
      }
    }

    final hasDescription =
        item.description != null && item.description!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip:
                context.tr(
                  shared.LocaleKeys.commonEdit,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Edit',
            onPressed: () =>
                MenuItemDetailActions.handleEditMenuItem(context, item),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip:
                context.tr(
                  shared.LocaleKeys.commonDelete,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Delete',
            onPressed: () =>
                MenuItemDetailActions.handleDeleteMenuItem(context, item),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MenuItemDetailHeaderCard(
                  item: item,
                  categoryName: categoryName,
                  subcategoryName: subcategoryName,
                ),
                if (hasDescription) ...[
                  const SizedBox(height: 16),
                  MenuItemDetailMetadataCard(item: item),
                ],
                const SizedBox(height: 16),
                MenuItemDetailPricingCard(item: item),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
