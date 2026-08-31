import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCartItemCard extends StatefulWidget {
  final OrderCartItem item;
  final bool showDetailedRemarks;

  const OrderCartItemCard({
    super.key,
    required this.item,
    this.showDetailedRemarks = true,
  });

  @override
  State<OrderCartItemCard> createState() => _OrderCartItemCardState();
}

class _OrderCartItemCardState extends State<OrderCartItemCard> {
  late final TextEditingController _remarksController;
  late final FocusNode _remarksFocusNode;

  static final List<String> _suggestionKeys = [
    shared.LocaleKeys.remarkJain,
    shared.LocaleKeys.remarkVegan,
    shared.LocaleKeys.remarkGlutenFree,
    shared.LocaleKeys.remarkNoOnionGarlic,
    shared.LocaleKeys.remarkLessChilli,
    shared.LocaleKeys.remarkLessOily,
    shared.LocaleKeys.remarkSpicy,
    shared.LocaleKeys.remarkExtraSpicy,
    shared.LocaleKeys.remarkMediumSpicy,
    shared.LocaleKeys.remarkNoSpice,
    shared.LocaleKeys.remarkLessSalt,
    shared.LocaleKeys.remarkLessSugar,
    shared.LocaleKeys.remarkExtraGravy,
    shared.LocaleKeys.remarkExtraCheese,
    shared.LocaleKeys.remarkNoOnion,
    shared.LocaleKeys.remarkCrispy,
    shared.LocaleKeys.remarkServeHot,
    shared.LocaleKeys.remarkSeparateSauce,
    shared.LocaleKeys.remarkLessIce,
    shared.LocaleKeys.remarkNoIce,
  ];

  static final Map<String, String> _fallbackTagNames = {
    shared.LocaleKeys.remarkJain: 'Jain',
    shared.LocaleKeys.remarkVegan: 'Vegan',
    shared.LocaleKeys.remarkGlutenFree: 'Gluten Free',
    shared.LocaleKeys.remarkNoOnionGarlic: 'No Onion Garlic',
    shared.LocaleKeys.remarkLessChilli: 'Less Chilli',
    shared.LocaleKeys.remarkLessOily: 'Less Oily',
    shared.LocaleKeys.remarkSpicy: 'Spicy',
    shared.LocaleKeys.remarkExtraSpicy: 'Extra Spicy',
    shared.LocaleKeys.remarkMediumSpicy: 'Medium Spicy',
    shared.LocaleKeys.remarkNoSpice: 'No Spice',
    shared.LocaleKeys.remarkLessSalt: 'Less Salt',
    shared.LocaleKeys.remarkLessSugar: 'Less Sugar',
    shared.LocaleKeys.remarkExtraGravy: 'Extra Gravy',
    shared.LocaleKeys.remarkExtraCheese: 'Extra Cheese',
    shared.LocaleKeys.remarkNoOnion: 'No Onion',
    shared.LocaleKeys.remarkCrispy: 'Crispy',
    shared.LocaleKeys.remarkServeHot: 'Serve Hot',
    shared.LocaleKeys.remarkSeparateSauce: 'Separate Sauce',
    shared.LocaleKeys.remarkLessIce: 'Less Ice',
    shared.LocaleKeys.remarkNoIce: 'No Ice',
  };

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(text: widget.item.remarks ?? '');
    _remarksFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant OrderCartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.remarks != oldWidget.item.remarks &&
        !_remarksFocusNode.hasFocus) {
      _remarksController.text = widget.item.remarks ?? '';
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _remarksFocusNode.dispose();
    super.dispose();
  }

  void _onRemarksChanged(String value) {
    context.read<MenuItemPickerBloc>().add(
      UpdateCartItemRemarksEvent(cartItem: widget.item, remarks: value.trim()),
    );
  }

  void _toggleSuggestionTag(String tagLabel) {
    final currentText = _remarksController.text.trim();
    List<String> tags = currentText.isEmpty
        ? []
        : currentText
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

    if (tags.contains(tagLabel)) {
      tags.removeWhere((t) => t == tagLabel);
    } else {
      tags.add(tagLabel);
    }

    final newText = tags.join(', ');
    _remarksController.text = newText;
    _onRemarksChanged(newText);
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets cardMargin = EdgeInsets.only(bottom: 10.0);
    const EdgeInsets cardPadding = EdgeInsets.all(12.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentRemarks = _remarksController.text.trim();
    final activeTags = currentRemarks.isEmpty
        ? <String>{}
        : currentRemarks
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toSet();

    return Card(
      elevation: 2,
      margin: cardMargin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Item Display Name + Category-Tab-Styled Quantity Controls
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item Name & Variation & Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${(widget.item.price * widget.item.quantity).toStringAsFixed(0)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Category-Tab-Styled Quantity Controls ( -  x Qty  + )
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: theme.colorScheme.error,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        context.read<MenuItemPickerBloc>().add(
                          UpdateCartItemQuantityEvent(
                            cartItem: widget.item,
                            newQuantity: widget.item.quantity - 1,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'x ${widget.item.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: theme.colorScheme.primary,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        context.read<MenuItemPickerBloc>().add(
                          UpdateCartItemQuantityEvent(
                            cartItem: widget.item,
                            newQuantity: widget.item.quantity + 1,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            if (widget.showDetailedRemarks) ...[
              const SizedBox(height: 10),

              // Horizontal Suggestion Hashtags Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final key in _suggestionKeys) ...[
                      Builder(
                        builder: (context) {
                          final fallback = _fallbackTagNames[key] ?? key;
                          final tagText = context.tr(key) ?? fallback;
                          final isSelected = activeTags.contains(tagText);

                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              label: Text(
                                '#$tagText',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: theme.colorScheme.primary,
                              backgroundColor: isDark
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : const Color(0xFFF0F0F0),
                              showCheckmark: false,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              onSelected: (_) => _toggleSuggestionTag(tagText),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Item Remark / Special Instruction Input Field
              TextField(
                controller: _remarksController,
                focusNode: _remarksFocusNode,
                onChanged: _onRemarksChanged,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      context.tr(shared.LocaleKeys.itemRemarksHint, track: shared.TrackConstants.tablePageTrack) ??
                      'Add special instruction or remark...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
