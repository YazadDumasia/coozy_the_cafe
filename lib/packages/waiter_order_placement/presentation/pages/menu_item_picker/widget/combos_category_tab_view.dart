import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/promotions_engine/domain/entities/combo.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../../domain/entities/order_cart_item.dart';
import '../../../bloc/menu_item_picker_bloc.dart';
import 'combo_picker_tile.dart';
import 'combos_tab_empty_view.dart';

class CombosCategoryTabView extends StatelessWidget {
  final List<Combo> combos;
  final String searchQuery;
  final VoidCallback? onReviewOrder;

  const CombosCategoryTabView({
    super.key,
    required this.combos,
    required this.searchQuery,
    this.onReviewOrder,
  });

  bool _matchesSearch(Combo combo) {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;

    final nameMatch = combo.name.toLowerCase().contains(q);
    final descMatch = (combo.description ?? '').toLowerCase().contains(q);
    final itemMatch = combo.items.any((it) {
      final itemName = it.menuItem?.name.toLowerCase() ?? '';
      final varName = it.variation?.name?.toLowerCase() ?? '';
      return itemName.contains(q) || varName.contains(q);
    });

    return nameMatch || descMatch || itemMatch;
  }

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 40.0;
    const EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: 10.0,
      vertical: 8.0,
    );
    const double horizontalPadding = 10.0;

    final state = context.watch<MenuItemPickerBloc>().state;
    final loadedState = state is MenuItemPickerLoadedState ? state : null;

    final filteredCombos = combos.where(_matchesSearch).toList();

    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Column(
      children: [
        Expanded(
          child: filteredCombos.isEmpty
              ? CombosTabEmptyView(onReviewOrder: onReviewOrder)
              : ListView.builder(
                  padding: contentPadding,
                  itemCount: filteredCombos.length,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemBuilder: (context, index) {
                    final combo = filteredCombos[index];
                    final comboId = combo.id ?? -(index + 1);

                    // Check quantity in cart
                    int qtyInCart = 0;
                    OrderCartItem? existingCartItem;
                    if (loadedState != null) {
                      for (final ci in loadedState.cartItems) {
                        if (ci.menuItemId == comboId ||
                            ci.name == '[Combo] ${combo.name}') {
                          qtyInCart = ci.quantity;
                          existingCartItem = ci;
                          break;
                        }
                      }
                    }

                    return ComboPickerTile(
                      combo: combo,
                      quantityInCart: qtyInCart,
                      onAdd: () {
                        context.read<MenuItemPickerBloc>().add(
                          AddCustomCartItemEvent(
                            OrderCartItem(
                              menuItemId: comboId,
                              name: '[Combo] ${combo.name}',
                              price: combo.sellingPrice,
                              quantity: 1,
                              remarks: combo.description,
                            ),
                          ),
                        );
                      },
                      onRemove: () {
                        if (existingCartItem != null) {
                          context.read<MenuItemPickerBloc>().add(
                            UpdateCartItemQuantityEvent(
                              cartItem: existingCartItem,
                              newQuantity: qtyInCart - 1,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
        ),

        // Bottom "Review Order" Button
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isLandscape ? 8 : 12,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      onPressed: onReviewOrder,
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.reviewOrderBtnText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Review Order',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
