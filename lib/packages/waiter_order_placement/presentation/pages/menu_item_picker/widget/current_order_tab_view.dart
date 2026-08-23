import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentOrderTabView extends StatelessWidget {
  final List<OrderCartItem> cartItems;
  final int tableId;
  final String tableName;
  final int? orderId;
  final bool isSubmitting;

  const CurrentOrderTabView({
    super.key,
    required this.cartItems,
    required this.tableId,
    required this.tableName,
    this.orderId,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 40.0;
    const EdgeInsets listPadding = EdgeInsets.all(10.0);
    const double horizontalPadding = 10.0;
    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    if (cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr(shared.LocaleKeys.noItemsAddedToCurrentOrderMsg) ??
                  'No items added to current order yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(shared.LocaleKeys.selectCategoryTabToBrowseMsg) ??
                  'Select a category tab above to browse and add items',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // List of items in current order
        Expanded(
          child: ListView.builder(
            padding: listPadding,
            itemCount: cartItems.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildGreenCartItemCard(context, item);
            },
          ),
        ),
        // Bottom Action Bar: Side-by-side Theme-based BILL NOW & SEND ORDER Buttons
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isLandscape ? 8 : 12,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (orderId != null) ...[
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
                        onPressed: isSubmitting
                            ? null
                            : () {
                                context.read<MenuItemPickerBloc>().add(
                                  SubmitOrderEvent(
                                    tableId: tableId,
                                    tableName: tableName,
                                    orderId: orderId,
                                  ),
                                );
                              },
                        child: Text(
                          context.tr(shared.LocaleKeys.billNowBtnText) ??
                              'Bill Now',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
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
                      onPressed: isSubmitting
                          ? null
                          : () {
                              context.read<MenuItemPickerBloc>().add(
                                SubmitOrderEvent(
                                  tableId: tableId,
                                  tableName: tableName,
                                  orderId: orderId,
                                ),
                              );
                            },
                      child: isSubmitting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              context.tr(shared.LocaleKeys.sendOrderBtnText) ??
                                  'Send Order',
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

  Widget _buildGreenCartItemCard(BuildContext context, OrderCartItem item) {
    const EdgeInsets cardMargin = EdgeInsets.only(bottom: 8.0);
    const EdgeInsets cardPadding = EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 12.0,
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final greenBgColor = isDark
        ? const Color(0xFF2E7D32)
        : const Color(0xFF4CAF50); // Green banner card matching screenshot

    return Card(
      elevation: 2,
      margin: cardMargin,
      color: greenBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: cardPadding,
        child: Row(
          children: [
            // Dish Name & Variation
            Expanded(
              child: Text(
                item.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 8),

            // Quantity indicator e.g. x 1
            Text(
              'x ${item.quantity}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(width: 8),

            // Action buttons to increment/decrement/remove
            InkWell(
              onTap: () {
                context.read<MenuItemPickerBloc>().add(
                  UpdateCartItemQuantityEvent(
                    cartItem: item,
                    newQuantity: item.quantity - 1,
                  ),
                );
              },
              child: const Icon(
                Icons.remove_circle,
                color: Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                context.read<MenuItemPickerBloc>().add(
                  UpdateCartItemQuantityEvent(
                    cartItem: item,
                    newQuantity: item.quantity + 1,
                  ),
                );
              },
              child: const Icon(
                Icons.add_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
