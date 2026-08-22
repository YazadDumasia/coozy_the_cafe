import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentOrderTabView extends StatelessWidget {
  final List<OrderCartItem> cartItems;
  final int tableId;
  final String tableName;
  final bool isSubmitting;

  const CurrentOrderTabView({
    super.key,
    required this.cartItems,
    required this.tableId,
    required this.tableName,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
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
              'No items added to current order yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
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
            padding: const EdgeInsets.all(10),
            itemCount: cartItems.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildGreenCartItemCard(context, item);
            },
          ),
        ),

        // Bottom "SEND ORDER" Green Button Container
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isLandscape ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C), // Vibrant Green
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
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
                              ),
                            );
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'SEND ORDER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreenCartItemCard(BuildContext context, OrderCartItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final greenBgColor = isDark
        ? const Color(0xFF2E7D32)
        : const Color(0xFF4CAF50); // Green banner card matching screenshot

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      color: greenBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
