import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_cart_item_card.dart';


class CurrentOrderTabView extends StatefulWidget {
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
  State<CurrentOrderTabView> createState() => _CurrentOrderTabViewState();
}

class _CurrentOrderTabViewState extends State<CurrentOrderTabView> {
  late final TextEditingController _overallRemarksController;
  late final FocusNode _overallRemarksFocusNode;
  bool _enableDetailedItemRemarks = true;

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
    final blocState = context.read<MenuItemPickerBloc>().state;
    final initialRemarks = (blocState is MenuItemPickerLoadedState)
        ? blocState.overallOrderRemarks
        : '';
    _overallRemarksController = TextEditingController(text: initialRemarks);
    _overallRemarksFocusNode = FocusNode();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled =
        prefs.getBool(shared.PreferencesKeys.enableDetailedItemRemarks.name) ??
        true;
    if (mounted) {
      setState(() {
        _enableDetailedItemRemarks = enabled;
      });
    }
  }

  @override
  void dispose() {
    _overallRemarksController.dispose();
    _overallRemarksFocusNode.dispose();
    super.dispose();
  }

  void _onOverallRemarksChanged(String value) {
    context.read<MenuItemPickerBloc>().add(
      UpdateOverallOrderRemarksEvent(value.trim()),
    );
  }

  void _toggleOverallTag(String tagLabel) {
    final currentText = _overallRemarksController.text.trim();
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
    _overallRemarksController.text = newText;
    _onOverallRemarksChanged(newText);
  }

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 40.0;
    const EdgeInsets listPadding = EdgeInsets.symmetric(
      horizontal: 10.0,
      vertical: 8.0,
    );
    const double horizontalPadding = 10.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    if (widget.cartItems.isEmpty) {
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
                  textAlign: TextAlign.center,
                )
                .inExpandedRow(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                )
                .paddingSymmetric(horizontal: 10),
            const SizedBox(height: 6),
            Text(
                  context.tr(shared.LocaleKeys.selectCategoryTabToBrowseMsg) ??
                      'Select a category tab above to browse and add items',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                )
                .inExpandedRow(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                )
                .paddingSymmetric(horizontal: 10),
          ],
        ),
      );
    }

    final blocState = context.watch<MenuItemPickerBloc>().state;
    if (blocState is MenuItemPickerLoadedState &&
        !_overallRemarksFocusNode.hasFocus &&
        _overallRemarksController.text != blocState.overallOrderRemarks) {
      _overallRemarksController.text = blocState.overallOrderRemarks;
    }

    final currentOverallText = _overallRemarksController.text.trim();
    final activeOverallTags = currentOverallText.isEmpty
        ? <String>{}
        : currentOverallText
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toSet();

    return Column(
      children: [
        // Top Section: Overall Order Remark Card with Quick Hashtags
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.tr(shared.LocaleKeys.overallOrderRemarksLabel) ??
                          'Overall Order Remarks',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Horizontal Quick Hashtags for Overall Order
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final key in _suggestionKeys) ...[
                        Builder(
                          builder: (context) {
                            final fallback = _fallbackTagNames[key] ?? key;
                            final tagText = context.tr(key) ?? fallback;
                            final isSelected = activeOverallTags.contains(
                              tagText,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: Text(
                                  '#$tagText',
                                  style: TextStyle(
                                    fontSize: 11,
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
                                    ? theme.colorScheme.surface
                                    : const Color(0xFFE8ECEF),
                                showCheckmark: false,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                onSelected: (_) => _toggleOverallTag(tagText),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _overallRemarksController,
                  focusNode: _overallRemarksFocusNode,
                  onChanged: _onOverallRemarksChanged,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText:
                        context.tr(shared.LocaleKeys.overallOrderRemarksHint) ??
                        'Add overall order remarks / instructions...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // List of items in current order
        Expanded(
          child: ListView.builder(
            padding: listPadding,
            itemCount: widget.cartItems.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              final item = widget.cartItems[index];
              return OrderCartItemCard(
                key: ValueKey('${item.menuItemId}_${item.variationId}'),
                item: item,
                showDetailedRemarks: _enableDetailedItemRemarks,
              );
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
                if (widget.orderId != null) ...[
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
                        onPressed: () {
                          final currentOrderId = widget.orderId?.toString() ?? '1';
                          context.push(
                            core.AppRoutePath.checkoutScreenRoute,
                            extra: currentOrderId,
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
                      onPressed: widget.isSubmitting
                          ? null
                          : () {
                              context.read<MenuItemPickerBloc>().add(
                                SubmitOrderEvent(
                                  tableId: widget.tableId,
                                  tableName: widget.tableName,
                                  orderId: widget.orderId,
                                ),
                              );
                            },
                      child: widget.isSubmitting
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
}
