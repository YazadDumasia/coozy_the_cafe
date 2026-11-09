import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item_variation.dart';

import '../../../domain/entities/combo.dart';
import '../../../domain/entities/combo_item.dart';
import '../../../domain/usecases/combo_usecases.dart';
import 'widget/menu_item_search_selector.dart';
import 'widget/selected_bundle_items_table.dart';

class ComboFormDialog extends StatefulWidget {
  final Combo? initialCombo;
  final SearchMenuItemsForComboUseCase searchUseCase;
  final GetMenuItemsCountForComboUseCase countUseCase;
  final Function(Combo combo) onSave;

  const ComboFormDialog({
    super.key,
    this.initialCombo,
    required this.searchUseCase,
    required this.countUseCase,
    required this.onSave,
  });

  @override
  State<ComboFormDialog> createState() => _ComboFormDialogState();
}

class _ComboFormDialogState extends State<ComboFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;

  late final TextEditingController _descriptionController;
  late final FocusNode _descriptionFocusNode;

  late final TextEditingController _sellingPriceController;
  late final FocusNode _sellingPriceFocusNode;

  late final TextEditingController _durationController;
  late final FocusNode _durationFocusNode;

  late final ValueNotifier<List<ComboItem>> _selectedItemsNotifier;
  late final ValueNotifier<bool> _isActiveNotifier;
  late final ValueNotifier<bool> _isTotalDurationModeNotifier;
  bool _isDurationManuallyEdited = false;
  bool _isProgrammaticDurationUpdate = false;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCombo;
    _nameController = TextEditingController(text: c?.name ?? '');
    _nameFocusNode = FocusNode();

    _descriptionController = TextEditingController(text: c?.description ?? '');
    _descriptionFocusNode = FocusNode();

    _sellingPriceController = TextEditingController(
      text: c != null ? c.sellingPrice.toStringAsFixed(2) : '',
    );
    _sellingPriceFocusNode = FocusNode();

    _durationController = TextEditingController(
      text: c?.duration != null ? c!.duration.toString() : '',
    );
    _durationFocusNode = FocusNode();
    _isDurationManuallyEdited = c?.duration != null && c!.duration! > 0;

    _durationController.addListener(_onDurationTextChanged);

    _selectedItemsNotifier = ValueNotifier<List<ComboItem>>(
      c?.items != null ? List.from(c!.items) : [],
    );
    _isActiveNotifier = ValueNotifier<bool>(c?.isActive ?? true);
    _isTotalDurationModeNotifier = ValueNotifier<bool>(false);
  }

  void _onDurationTextChanged() {
    if (_isProgrammaticDurationUpdate) return;
    if (_durationFocusNode.hasFocus) {
      _isDurationManuallyEdited = true;
    }
  }

  @override
  void dispose() {
    _durationController.removeListener(_onDurationTextChanged);
    _nameController.dispose();
    _nameFocusNode.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    _sellingPriceController.dispose();
    _sellingPriceFocusNode.dispose();
    _durationController.dispose();
    _durationFocusNode.dispose();
    _selectedItemsNotifier.dispose();
    _isActiveNotifier.dispose();
    _isTotalDurationModeNotifier.dispose();
    super.dispose();
  }

  double _calculateOriginalTotal(List<ComboItem> items) {
    return items.fold<double>(0.0, (sum, i) => sum + i.totalPrice);
  }

  double get _currentSellingPrice {
    return double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
  }

  void _recalculateDuration(List<ComboItem> items) {
    if (_isDurationManuallyEdited) {
      PlatformUtils.debugLog(
        ComboFormDialog,
        '_recalculateDuration: skipped because duration was manually edited by user',
      );
      return;
    }

    final isTotal = _isTotalDurationModeNotifier.value;
    int computedDur = 0;

    if (isTotal) {
      // Cumulative total prep duration (each item duration * its quantity)
      for (final i in items) {
        final d = i.duration;
        if (d != null && d > 0) {
          computedDur += (d * i.quantity);
        }
      }
    } else {
      // Longest single dish prep duration (parallel prep)
      for (final i in items) {
        final d = i.duration;
        if (d != null && d > computedDur) {
          computedDur = d;
        }
      }
    }

    _isProgrammaticDurationUpdate = true;
    _durationController.text = computedDur > 0 ? computedDur.toString() : '';
    _isProgrammaticDurationUpdate = false;

    PlatformUtils.debugLog(
      ComboFormDialog,
      '_recalculateDuration: computedDur=$computedDur mins (mode: ${isTotal ? 'Total Duration' : 'Longest Item Duration'}) from ${items.length} items',
    );
  }

  void _onMenuItemSelected(MenuItem item, MenuItemVariation? variation) {
    PlatformUtils.debugLog(
      ComboFormDialog,
      '_onMenuItemSelected: item=${item.name} (id: ${item.id}), variation=${variation?.name} (id: ${variation?.id}), dur=${variation?.duration ?? item.duration}',
    );
    final currentList = List<ComboItem>.from(_selectedItemsNotifier.value);
    final existingIndex = currentList.indexWhere(
      (i) => i.menuItemId == item.id && i.variationId == variation?.id,
    );

    if (existingIndex >= 0) {
      final existing = currentList[existingIndex];
      currentList[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      currentList.add(
        ComboItem(
          comboId: widget.initialCombo?.id ?? 0,
          menuItemId: item.id!,
          variationId: variation?.id,
          quantity: 1,
          menuItem: item,
          variation: variation,
        ),
      );
    }

    _selectedItemsNotifier.value = currentList;

    // Auto-suggest combo name if empty
    if (_nameController.text.trim().isEmpty && currentList.isNotEmpty) {
      final names = currentList.map((e) => e.menuItem?.name ?? '').toList();
      _nameController.text = names.take(3).join(' + ');
    }

    // Auto-suggest selling price if empty or 0
    if (_sellingPriceController.text.trim().isEmpty ||
        _currentSellingPrice == 0.0) {
      _sellingPriceController.text = _calculateOriginalTotal(currentList)
          .toStringAsFixed(2);
    }

    // Auto-recalculate longest preparation duration
    _recalculateDuration(currentList);

    PlatformUtils.debugLog(
      ComboFormDialog,
      '_onMenuItemSelected: totalItems=${currentList.length}, originalTotal=${_calculateOriginalTotal(currentList)}',
    );
  }

  void _onQuantityChanged(int index, int newQty) {
    final currentList = List<ComboItem>.from(_selectedItemsNotifier.value);
    if (index >= 0 && index < currentList.length) {
      PlatformUtils.debugLog(
        ComboFormDialog,
        '_onQuantityChanged: item=${currentList[index].menuItem?.name}, oldQty=${currentList[index].quantity}, newQty=$newQty',
      );
      currentList[index] = currentList[index].copyWith(quantity: newQty);
      _selectedItemsNotifier.value = currentList;
      _recalculateDuration(currentList);
    }
  }

  void _onRemoveItem(int index) {
    final currentList = List<ComboItem>.from(_selectedItemsNotifier.value);
    if (index >= 0 && index < currentList.length) {
      PlatformUtils.debugLog(
        ComboFormDialog,
        '_onRemoveItem: removing index=$index (${currentList[index].menuItem?.name})',
      );
      currentList.removeAt(index);
      _selectedItemsNotifier.value = currentList;
      _recalculateDuration(currentList);
    }
  }

  void _onSubmit() {
    PlatformUtils.debugLog(ComboFormDialog, '_onSubmit triggered');
    if (!_formKey.currentState!.validate()) {
      PlatformUtils.debugLog(
        ComboFormDialog,
        '_onSubmit: form validation failed',
      );
      return;
    }

    final items = _selectedItemsNotifier.value;
    if (items.length < 2) {
      PlatformUtils.debugLog(
        ComboFormDialog,
        '_onSubmit: validation failed - insufficient items (${items.length} < 2)',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least 2 menu items to create a combo or bundle.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final sellingPrice =
        double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
    final durationSeconds = int.tryParse(_durationController.text.trim());
    final originalTotal = _calculateOriginalTotal(items);
    final now =
        DateUtil.localFormatDateTime(
          DateTime.now().toUtc(),
          DateUtil.dateFormat,
        ) ??
        DateTime.now().toUtc().toIso8601String();

    final combo = Combo(
      id: widget.initialCombo?.id,
      hashId: widget.initialCombo?.hashId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      originalPrice: originalTotal,
      sellingPrice: sellingPrice,
      duration: durationSeconds,
      isActive: _isActiveNotifier.value,
      sortOrderIndex: widget.initialCombo?.sortOrderIndex ?? 0,
      creationDate: widget.initialCombo?.creationDate ?? now,
      modificationDate: now,
      items: items,
    );

    PlatformUtils.debugLog(
      ComboFormDialog,
      '_onSubmit: saving combo "${combo.name}" with ${combo.items.length} items, sellingPrice=${combo.sellingPrice}, duration=${combo.duration}',
    );
    widget.onSave(combo);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.sizeOf(context);
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);
    final isMobile = shared.ResponsiveLayout.isMobile(context);

    // Dialog layout: 2-column on Desktop and Landscape Tablet (width >= 800), stacked/scrollable on Mobile & narrow Tablet
    final useTwoColumn = isDesktop || (isTablet && screenSize.width >= 800);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 0 : 20),
      ),
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : (isTablet ? 20 : 32),
        vertical: isMobile ? 0 : (isTablet ? 20 : 32),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1080 : (isTablet ? 850 : double.infinity),
          maxHeight: isMobile
              ? double.infinity
              : screenSize.height * (isTablet ? 0.92 : 0.88),
          minHeight: isMobile ? screenSize.height : 0,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.initialCombo == null
                  ? 'Create Combo / Bundle'
                  : 'Edit Combo / Bundle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 20,
              ),
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              FilledButton.icon(
                onPressed: _onSubmit,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(isMobile ? 'Save' : 'Save Combo'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 18,
                    vertical: isMobile ? 8 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 10 : 16),
            ],
          ),
          body: Form(
            key: _formKey,
            child: useTwoColumn
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left: search menu item selector
                      Expanded(
                        flex: isDesktop ? 5 : 6,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: MenuItemSearchSelector(
                            searchUseCase: widget.searchUseCase,
                            countUseCase: widget.countUseCase,
                            onItemSelected: _onMenuItemSelected,
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      // Right: combo details, selected items & pricing
                      Expanded(
                        flex: isDesktop ? 6 : 6,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: _buildFormFields(colorScheme, theme),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(isMobile ? 14 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFormFields(colorScheme, theme),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu_rounded,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Select Menu Items to Bundle',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: isMobile ? 420 : 460,
                          child: MenuItemSearchSelector(
                            searchUseCase: widget.searchUseCase,
                            countUseCase: widget.countUseCase,
                            onItemSelected: _onMenuItemSelected,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          decoration: InputDecoration(
            labelText: 'Combo / Bundle Name *',
            hintText: 'e.g. Breakfast Duo, Coffee + Pastry',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.fastfood_outlined),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Combo name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Briefly describe this combo offer...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.description_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active for Ordering',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isActiveNotifier,
              builder: (context, isActive, _) {
                return Switch.adaptive(
                  value: isActive,
                  onChanged: (val) {
                    _isActiveNotifier.value = val;
                  },
                  activeThumbColor: colorScheme.primary,
                  activeTrackColor: colorScheme.primary.withValues(alpha: 0.38),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<List<ComboItem>>(
          valueListenable: _selectedItemsNotifier,
          builder: (context, selectedItems, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bundled Items (${selectedItems.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SelectedBundleItemsTable(
                  items: selectedItems,
                  onQuantityChanged: _onQuantityChanged,
                  onRemoveItem: _onRemoveItem,
                ),
                const SizedBox(height: 20),
                // Pricing calculation card
                ListenableBuilder(
                  listenable: _sellingPriceController,
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Regular Items Total:',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                CurrencyFormatter.format(value: origTotal),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: discountAmt > 0
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _sellingPriceController,
                            focusNode: _sellingPriceFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Custom Combo Selling Price *',
                              hintText: '0.00',
                              prefixText: '${CurrencyFormatter.primarySymbol} ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Selling price is required';
                              }
                              final parsed = double.tryParse(v.trim());
                              if (parsed == null || parsed < 0) {
                                return 'Please enter a valid positive price';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          ValueListenableBuilder<bool>(
                            valueListenable: _isTotalDurationModeNotifier,
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
                                              'Duration Calculation Mode',
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              isTotalMode
                                                  ? 'Cumulative Sum (Total of all items)'
                                                  : 'Longest Dish (Parallel prep)',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontSize: 11,
                                                    color: colorScheme.onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            isTotalMode ? 'Total' : 'Longest',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.primary,
                                                ),
                                          ),
                                          const SizedBox(width: 4),
                                          Switch.adaptive(
                                            value: isTotalMode,
                                            onChanged: (val) {
                                              _isTotalDurationModeNotifier
                                                      .value =
                                                  val;
                                              _isDurationManuallyEdited = false;
                                              _recalculateDuration(
                                                _selectedItemsNotifier.value,
                                              );
                                            },
                                            activeThumbColor:
                                                colorScheme.primary,
                                            activeTrackColor: colorScheme
                                                .primary
                                                .withValues(alpha: 0.38),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _durationController,
                                    focusNode: _durationFocusNode,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Preparation Duration (Minutes)',
                                      hintText: 'e.g. 15',
                                      prefixIcon: const Icon(
                                        Icons.timer_outlined,
                                      ),
                                      suffixText: 'mins',
                                      helperText: isTotalMode
                                          ? 'Sum of all dish durations (sequential preparation)'
                                          : 'Longest dish duration (parallel preparation)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          if (discountAmt > 0) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Customer Savings:',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.tertiary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '-${CurrencyFormatter.format(value: discountAmt)} (${discountPct.toStringAsFixed(0)}% OFF)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.tertiary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
