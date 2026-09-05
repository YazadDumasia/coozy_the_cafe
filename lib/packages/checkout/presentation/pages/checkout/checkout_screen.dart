import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/checkout_bloc.dart';
import '../../utils/responsive_modal.dart';
import 'checkout_screen_actions.dart';

import 'widget/cart_item_tile.dart';
import 'widget/checkout_summary_card.dart';
import 'widget/edit_cart_item_dialog.dart';
import 'widget/sticky_charge_bar.dart';

class CheckoutScreen extends StatefulWidget {
  final String orderId;

  const CheckoutScreen({super.key, required this.orderId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with CheckoutScreenActions {
  @override
  void initState() {
    super.initState();
    // Fetch order details automatically on initial load using the provided orderId
    context.read<CheckoutBloc>().add(CheckoutFetchStarted(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('POS Checkout (Order #${widget.orderId})'),
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error loading order details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CheckoutBloc>().add(
                          CheckoutFetchStarted(widget.orderId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cart Items List
                      BlocBuilder<CheckoutBloc, CheckoutState>(
                        builder: (context, state) {
                          if (state.cartItems.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(32.0),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.remove_shopping_cart_outlined,
                                    size: 48,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Cart is Empty',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            itemCount: state.cartItems.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final item = state.cartItems[index];
                              return CartItemTile(
                                item: item,
                                onEdit: () {
                                  showResponsiveModal(
                                    context: context,
                                    child: EditCartItemDialog(
                                      initialName: item.name,
                                      initialQuantity: item.quantity,
                                      initialUnitPrice: item.unitPrice,
                                      onSave: (newQty, newPrice) {
                                        context.read<CheckoutBloc>().add(
                                          CheckoutItemUpdated(
                                            item.copyWith(
                                              quantity: newQty,
                                              unitPrice: newPrice,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // "Add New Item" & "Scan Barcode" Row directly below cart list
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Item'),
                                onPressed: () => handleAddItem(context),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.qr_code_scanner_rounded),
                              label: const Text('Scan'),
                              onPressed: () => handleBarcodeScanner(context),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dynamic Summary Card
                      const CheckoutSummaryCard(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Sticky Charge Bar at bottom
              const StickyChargeBar(),
            ],
          );
        },
      ),
    );
  }
}
