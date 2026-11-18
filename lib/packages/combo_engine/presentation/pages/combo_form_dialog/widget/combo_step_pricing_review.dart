import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../../domain/entities/combo_item.dart';
import 'selected_bundle_items_table.dart';

enum ComboPricingMode { fixedPrice, percentageDiscount }

class ComboStepPricingReview extends StatefulWidget {
  final TextEditingController sellingPriceController;
  final FocusNode sellingPriceFocusNode;
  final TextEditingController discountPercentController;
  final FocusNode discountPercentFocusNode;
  final TextEditingController durationController;
  final FocusNode durationFocusNode;
  final ValueNotifier<List<ComboItem>> selectedItemsNotifier;
  final ValueNotifier<bool> isTotalDurationModeNotifier;
  final VoidCallback onRecalculateDuration;
  final Function(int index, int newQuantity) onQuantityChanged;
  final Function(int index) onRemoveItem;

  const ComboStepPricingReview({
    super.key,
    required this.sellingPriceController,
    required this.sellingPriceFocusNode,
    required this.discountPercentController,
    required this.discountPercentFocusNode,
    required this.durationController,
    required this.durationFocusNode,
    required this.selectedItemsNotifier,
    required this.isTotalDurationModeNotifier,
    required this.onRecalculateDuration,
    required this.onQuantityChanged,
    required this.onRemoveItem,
  });

  @override
  State<ComboStepPricingReview> createState() => _ComboStepPricingReviewState();
}

class _ComboStepPricingReviewState extends State<ComboStepPricingReview> {
  ComboPricingMode _pricingMode = ComboPricingMode.fixedPrice;
  bool _isSyncing = false;

  double _calculateOriginalTotal(List<ComboItem> items) {
    return items.fold<double>(0.0, (sum, i) => sum + i.totalPrice);
  }

  double get _currentSellingPrice {
    return double.tryParse(widget.sellingPriceController.text.trim()) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    widget.sellingPriceController.addListener(_onSellingPriceChanged);
    widget.discountPercentController.addListener(_onDiscountPercentChanged);
    _initialSyncDiscountPercent();
  }

  void _initialSyncDiscountPercent() {
    final origTotal = _calculateOriginalTotal(
      widget.selectedItemsNotifier.value,
    );
    final sellPrice = _currentSellingPrice;
    if (origTotal > 0 && sellPrice < origTotal && sellPrice > 0) {
      final pct = ((origTotal - sellPrice) / origTotal) * 100;
      _isSyncing = true;
      widget.discountPercentController.text = pct % 1 == 0
          ? pct.toInt().toString()
          : pct.toStringAsFixed(1);
      _isSyncing = false;
    }
  }

  void _onSellingPriceChanged() {
    if (_isSyncing) return;
    final origTotal = _calculateOriginalTotal(
      widget.selectedItemsNotifier.value,
    );
    final sellPrice = _currentSellingPrice;
    if (origTotal > 0 && sellPrice >= 0 && sellPrice <= origTotal) {
      final pct = ((origTotal - sellPrice) / origTotal) * 100;
      _isSyncing = true;
      widget.discountPercentController.text = pct % 1 == 0
          ? pct.toInt().toString()
          : pct.toStringAsFixed(1);
      _isSyncing = false;
    } else if (sellPrice > origTotal) {
      _isSyncing = true;
      widget.discountPercentController.text = '0';
      _isSyncing = false;
    }
  }

  void _onDiscountPercentChanged() {
    if (_isSyncing) return;
    if (_pricingMode != ComboPricingMode.percentageDiscount) return;
    final origTotal = _calculateOriginalTotal(
      widget.selectedItemsNotifier.value,
    );
    final pct =
        double.tryParse(widget.discountPercentController.text.trim()) ?? 0.0;
    if (pct >= 0 && pct <= 100 && origTotal > 0) {
      final calculatedSelling = origTotal * (1.0 - (pct / 100.0));
      _isSyncing = true;
      widget.sellingPriceController.text = calculatedSelling % 1 == 0
          ? calculatedSelling.toInt().toString()
          : calculatedSelling.toStringAsFixed(2);
      _isSyncing = false;
    }
  }

  @override
  void dispose() {
    widget.sellingPriceController.removeListener(_onSellingPriceChanged);
    widget.discountPercentController.removeListener(_onDiscountPercentChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pricing Summary & Inputs Card
          ValueListenableBuilder<List<ComboItem>>(
            valueListenable: widget.selectedItemsNotifier,
            builder: (context, selectedItems, _) {
              return ListenableBuilder(
                listenable: widget.sellingPriceController,
                builder: (context, _) {
                  final origTotal = _calculateOriginalTotal(selectedItems);
                  final sellPrice = _currentSellingPrice;
                  final discountAmt = origTotal > sellPrice
                      ? origTotal - sellPrice
                      : 0.0;
                  final discountPct = origTotal > 0 && sellPrice < origTotal
                      ? ((origTotal - sellPrice) / origTotal) * 100
                      : 0.0;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Regular Items Total Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr(
                                    shared
                                        .LocaleKeys
                                        .comboFormDialogRegularItemsTotal,
                                    track: shared.TrackConstants.comboPageTrack,
                                  ) ??
                                  'Regular Items Total:',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(value: origTotal),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: discountAmt > 0
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: discountAmt > 0
                                    ? colorScheme.onSurface.withValues(
                                        alpha: 0.5,
                                      )
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Toggle Segmented Control: Fixed Price vs. Percentage Discount
                        Row(
                          children: [
                            Expanded(
                              child: SegmentedButton<ComboPricingMode>(
                                segments: [
                                  ButtonSegment<ComboPricingMode>(
                                    value: ComboPricingMode.fixedPrice,
                                    label: Text(
                                      context.tr(
                                            shared
                                                .LocaleKeys
                                                .comboFormDialogDiscountModeAmount,
                                            track: shared
                                                .TrackConstants
                                                .comboPageTrack,
                                          ) ??
                                          'Fixed Price',
                                    ),
                                    icon: const Icon(
                                      Icons.currency_rupee,
                                      size: 16,
                                    ),
                                  ),
                                  ButtonSegment<ComboPricingMode>(
                                    value: ComboPricingMode.percentageDiscount,
                                    label: Text(
                                      context.tr(
                                            shared
                                                .LocaleKeys
                                                .comboFormDialogDiscountModePercentage,
                                            track: shared
                                                .TrackConstants
                                                .comboPageTrack,
                                          ) ??
                                          'Discount %',
                                    ),
                                    icon: const Icon(
                                      Icons.percent_rounded,
                                      size: 16,
                                    ),
                                  ),
                                ],
                                selected: {_pricingMode},
                                onSelectionChanged:
                                    (Set<ComboPricingMode> newSelection) {
                                      setState(() {
                                        _pricingMode = newSelection.first;
                                      });
                                      if (_pricingMode ==
                                          ComboPricingMode.percentageDiscount) {
                                        widget.discountPercentFocusNode
                                            .requestFocus();
                                      } else {
                                        widget.sellingPriceFocusNode
                                            .requestFocus();
                                      }
                                    },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Dual Inputs: Either Fixed Selling Price or Discount Percentage
                        if (_pricingMode == ComboPricingMode.fixedPrice) ...[
                          Text(
                            context.tr(
                                  shared
                                      .LocaleKeys
                                      .comboFormDialogSellingPriceLabel,
                                  track: shared.TrackConstants.comboPageTrack,
                                ) ??
                                'Custom Combo Selling Price *',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: widget.sellingPriceController,
                            focusNode: widget.sellingPriceFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  context.tr(
                                    shared
                                        .LocaleKeys
                                        .comboFormDialogSellingPriceHint,
                                    track: shared.TrackConstants.comboPageTrack,
                                  ) ??
                                  '0.00',
                              prefixText: '${CurrencyFormatter.primarySymbol} ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return context.tr(
                                      shared
                                          .LocaleKeys
                                          .comboFormDialogSellingPriceRequired,
                                      track:
                                          shared.TrackConstants.comboPageTrack,
                                    ) ??
                                    'Selling price is required';
                              }
                              final parsed = double.tryParse(v.trim());
                              if (parsed == null || parsed < 0) {
                                return context.tr(
                                      shared
                                          .LocaleKeys
                                          .comboFormDialogSellingPriceInvalid,
                                      track:
                                          shared.TrackConstants.comboPageTrack,
                                    ) ??
                                    'Please enter a valid positive price';
                              }
                              return null;
                            },
                          ),
                        ] else ...[
                          Text(
                            context.tr(
                                  shared
                                      .LocaleKeys
                                      .comboFormDialogDiscountPercentLabel,
                                  track: shared.TrackConstants.comboPageTrack,
                                ) ??
                                'Discount Percentage (%) *',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: widget.discountPercentController,
                            focusNode: widget.discountPercentFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  context.tr(
                                    shared
                                        .LocaleKeys
                                        .comboFormDialogDiscountPercentHint,
                                    track: shared.TrackConstants.comboPageTrack,
                                  ) ??
                                  '0 - 100',
                              suffixText: '%',
                              prefixIcon: const Icon(Icons.percent_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return context.tr(
                                      shared
                                          .LocaleKeys
                                          .comboFormDialogDiscountPercentRequired,
                                      track:
                                          shared.TrackConstants.comboPageTrack,
                                    ) ??
                                    'Discount percentage is required';
                              }
                              final parsed = double.tryParse(v.trim());
                              if (parsed == null ||
                                  parsed < 0 ||
                                  parsed > 100) {
                                return context.tr(
                                      shared
                                          .LocaleKeys
                                          .comboFormDialogDiscountPercentInvalid,
                                      track:
                                          shared.TrackConstants.comboPageTrack,
                                    ) ??
                                    'Enter discount % between 0 and 100';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // Display computed final selling price in percentage mode
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr(
                                      shared
                                          .LocaleKeys
                                          .comboFormDialogEffectiveSellingPrice,
                                      track:
                                          shared.TrackConstants.comboPageTrack,
                                    ) ??
                                    'Effective Combo Selling Price:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(value: sellPrice),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Customer Savings Banner
                        if (discountAmt > 0) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isCompact = constraints.maxWidth < 360;

                                if (isCompact) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_offer_rounded,
                                            size: 18,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              context.tr(
                                                    shared
                                                        .LocaleKeys
                                                        .comboFormDialogCustomerSavings,
                                                    track: shared
                                                        .TrackConstants
                                                        .comboPageTrack,
                                                  ) ??
                                                  'Customer Savings:',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '-${CurrencyFormatter.format(value: discountAmt)} (${discountPct.toStringAsFixed(0)}% OFF)',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_offer_rounded,
                                          size: 18,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .comboFormDialogCustomerSavings,
                                                track: shared
                                                    .TrackConstants
                                                    .comboPageTrack,
                                              ) ??
                                              'Customer Savings:',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '-${CurrencyFormatter.format(value: discountAmt)} (${discountPct.toStringAsFixed(0)}% OFF)',
                                        textAlign: TextAlign.end,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 14),

                        // Preparation Duration Section
                        ValueListenableBuilder<bool>(
                          valueListenable: widget.isTotalDurationModeNotifier,
                          builder: (context, isTotalMode, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.tr(
                                                  shared
                                                      .LocaleKeys
                                                      .comboFormDialogDurationModeTitle,
                                                  track: shared
                                                      .TrackConstants
                                                      .comboPageTrack,
                                                ) ??
                                                'Duration Calculation Mode',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isTotalMode
                                                ? (context.tr(
                                                        shared
                                                            .LocaleKeys
                                                            .comboFormDialogDurationModeTotal,
                                                        track: shared
                                                            .TrackConstants
                                                            .comboPageTrack,
                                                      ) ??
                                                      'Cumulative Sum (Total of all items)')
                                                : (context.tr(
                                                        shared
                                                            .LocaleKeys
                                                            .comboFormDialogDurationModeLongest,
                                                        track: shared
                                                            .TrackConstants
                                                            .comboPageTrack,
                                                      ) ??
                                                      'Longest Dish (Parallel prep)'),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.65),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isTotalMode
                                              ? (context.tr(
                                                      shared
                                                          .LocaleKeys
                                                          .comboFormDialogDurationModeTotalShort,
                                                      track: shared
                                                          .TrackConstants
                                                          .comboPageTrack,
                                                    ) ??
                                                    'Total')
                                              : (context.tr(
                                                      shared
                                                          .LocaleKeys
                                                          .comboFormDialogDurationModeLongestShort,
                                                      track: shared
                                                          .TrackConstants
                                                          .comboPageTrack,
                                                    ) ??
                                                    'Longest'),
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                        ),
                                        const SizedBox(width: 4),
                                        Switch.adaptive(
                                          value: isTotalMode,
                                          onChanged: (val) {
                                            widget
                                                    .isTotalDurationModeNotifier
                                                    .value =
                                                val;
                                            widget.onRecalculateDuration();
                                          },
                                          activeThumbColor: colorScheme.primary,
                                          activeTrackColor: colorScheme.primary
                                              .withValues(alpha: 0.38),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: widget.durationController,
                                  focusNode: widget.durationFocusNode,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .comboFormDialogDurationLabel,
                                          track: shared
                                              .TrackConstants
                                              .comboPageTrack,
                                        ) ??
                                        'Preparation Duration (Minutes)',
                                    hintText:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .comboFormDialogDurationHint,
                                          track: shared
                                              .TrackConstants
                                              .comboPageTrack,
                                        ) ??
                                        'e.g. 15',
                                    prefixIcon: const Icon(
                                      Icons.timer_outlined,
                                    ),
                                    suffixText:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .comboFormDialogDurationSuffix,
                                          track: shared
                                              .TrackConstants
                                              .comboPageTrack,
                                        ) ??
                                        'mins',
                                    helperText: isTotalMode
                                        ? (context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .comboFormDialogDurationHelperTotal,
                                                track: shared
                                                    .TrackConstants
                                                    .comboPageTrack,
                                              ) ??
                                              'Sum of all dish durations (sequential preparation)')
                                        : (context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .comboFormDialogDurationHelperLongest,
                                                track: shared
                                                    .TrackConstants
                                                    .comboPageTrack,
                                              ) ??
                                              'Longest dish duration (parallel preparation)'),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // Review of Bundled Items Table
          ValueListenableBuilder<List<ComboItem>>(
            valueListenable: widget.selectedItemsNotifier,
            builder: (context, items, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr(
                              shared
                                  .LocaleKeys
                                  .comboFormDialogReviewBundledItems,
                              track: shared.TrackConstants.comboPageTrack,
                              params: {'count': items.length.toString()},
                            ) ??
                            'Review Bundled Items (${items.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (items.length < 2)
                        Text(
                          context.tr(
                                shared
                                    .LocaleKeys
                                    .comboFormDialogMinItemsRequired,
                                track: shared.TrackConstants.comboPageTrack,
                              ) ??
                              'Minimum 2 items required',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SelectedBundleItemsTable(
                    items: items,
                    onQuantityChanged: widget.onQuantityChanged,
                    onRemoveItem: widget.onRemoveItem,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
