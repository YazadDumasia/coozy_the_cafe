import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_purchase_screen_actions.dart';
import 'widgets/purchase_history_list_item.dart';

import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/item_purchase_bloc.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/item_purchase_event.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/item_purchase_state.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class AddPurchaseScreen extends StatefulWidget {
  final InventoryItem item;
  const AddPurchaseScreen({super.key, required this.item});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dispatch load purchases for this specific item
    context.read<ItemPurchaseBloc>().add(
      LoadPurchasesForInventory(widget.item),
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
                shared.LocaleKeys.purchaseAddAppbarTitle,
                track: shared.TrackConstants.purchasePageTrack,
                params: {"itemName": widget.item.name ?? ''},
              ) ??
              'Purchase: ${widget.item.name}',
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(8.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                          shared.LocaleKeys.purchaseAddHeaderMsg,
                          track: shared.TrackConstants.purchasePageTrack,
                        ) ??
                        'Add New Purchase',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _qtyController,
                          decoration: InputDecoration(
                            hintText:
                                context.tr(
                                  shared.LocaleKeys.purchaseQuantityHintText,
                                  track:
                                      shared.TrackConstants.purchasePageTrack,
                                  params: {
                                    "purchase_unit":
                                        widget.item.purchaseUnit ?? 'units',
                                  },
                                ) ??
                                'Quantity (${widget.item.purchaseUnit})',
                            labelText:
                                context.tr(
                                  shared.LocaleKeys.purchaseQuantityLabelText,
                                  track:
                                      shared.TrackConstants.purchasePageTrack,
                                ) ??
                                'Quantity',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return context.tr(
                                    shared.LocaleKeys.commonRequired,
                                    track: shared.TrackConstants.commonTrack,
                                  ) ??
                                  'Required';
                            }

                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText:
                                context.tr(
                                  shared.LocaleKeys.purchaseTotalPrice,
                                  track:
                                      shared.TrackConstants.purchasePageTrack,
                                ) ??
                                'Total Price',
                            hintText:
                                context.tr(
                                  shared.LocaleKeys.purchaseTotalPrice,
                                  track:
                                      shared.TrackConstants.purchasePageTrack,
                                ) ??
                                'Total Price',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return context.tr(
                                    shared.LocaleKeys.commonRequired,
                                    track: shared.TrackConstants.commonTrack,
                                  ) ??
                                  'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () =>
                          AddPurchaseScreenActions.handleSubmitPurchase(
                            context: context,
                            formKey: _formKey,
                            item: widget.item,
                            qtyController: _qtyController,
                            priceController: _priceController,
                          ),
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.purchaseSavePurchase,
                              track: shared.TrackConstants.purchasePageTrack,
                            ) ??
                            'Save Purchase',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: BlocBuilder<ItemPurchaseBloc, ItemPurchaseState>(
            builder: (context, state) {
              if (state is ItemPurchaseLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ItemPurchaseError) {
                return Center(
                  child: Text(
                    '${context.tr(shared.LocaleKeys.commonError, track: shared.TrackConstants.commonTrack) ?? 'Error'}: ${state.message}',
                  ),
                );
              } else if (state is ItemPurchasesLoaded) {
                final purchases = state.purchases;
                if (purchases.isEmpty) {
                  return Center(
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.purchaseNoPurchaseHistory,
                            track: shared.TrackConstants.purchasePageTrack,
                          ) ??
                          'No purchase history.',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: purchases.length,
                  itemBuilder: (context, index) {
                    final p = purchases[index];
                    return PurchaseHistoryListItem(record: p);
                  },
                );
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
