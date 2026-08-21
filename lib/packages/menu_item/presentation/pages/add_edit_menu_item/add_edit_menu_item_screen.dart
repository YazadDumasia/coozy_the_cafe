import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'add_edit_menu_item_screen_actions.dart';

import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item_variation.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class AddEditMenuItemScreen extends StatefulWidget {
  final MenuItem? item;
  const AddEditMenuItemScreen({super.key, this.item});

  @override
  State<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ── Controllers ──────────────────────────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  late final TextEditingController _sellingUnitQtyController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;

  // ── Focus nodes ──────────────────────────────────────────────────────────
  late final FocusNode _nameFocusNode;
  late final FocusNode _descriptionFocusNode;
  late final FocusNode _durationFocusNode;
  late final FocusNode _foodTypeFocusNode;
  late final FocusNode _measuringUnitFocusNode;
  late final FocusNode _sellingUnitQtyFocusNode;
  late final FocusNode _costPriceFocusNode;
  late final FocusNode _sellingPriceFocusNode;

  // ── Value notifiers ──────────────────────────────────────────────────────
  final ValueNotifier<String?> _foodTypeNotifier = ValueNotifier(null);
  final ValueNotifier<int?> _categoryIdNotifier = ValueNotifier(null);
  final ValueNotifier<int?> _subcategoryIdNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isTodayAvailableNotifier = ValueNotifier(false);
  final ValueNotifier<String?> _measuringUnitNotifier = ValueNotifier(null);
  final ValueNotifier<double> _profitMarginNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isSimpleVariationNotifier = ValueNotifier<bool>(
    true,
  );

  // ── Duration ─────────────────────────────────────────────────────────────
  Duration _selectedDuration = Duration.zero;

  // ── Variations ───────────────────────────────────────────────────────────
  final List<_VariationFormModel> _variations = <_VariationFormModel>[];

  // ── Static data ── key: locale key, value: English fallback (stored in DB) ──
  static const Map<String, String> _foodTypes = <String, String>{
    'menu_item_page_food_type_vegetarian': 'Vegetarian',
    'menu_item_page_food_type_lacto_vegetarian': 'Lacto-Vegetarian',
    'menu_item_page_food_type_ovo_vegetarian': 'Ovo-Vegetarian',
    'menu_item_page_food_type_lacto_ovo_vegetarian': 'Lacto-Ovo Vegetarian',
    'menu_item_page_food_type_vegan': 'Vegan',
    'menu_item_page_food_type_non_vegetarian': 'Non-Vegetarian',
    'menu_item_page_food_type_poultry': 'Poultry',
    'menu_item_page_food_type_red_meat': 'Red Meat',
    'menu_item_page_food_type_seafood': 'Seafood',
    'menu_item_page_food_type_game': 'Game',
    'menu_item_page_food_type_pescatarian': 'Pescatarian',
    'menu_item_page_food_type_flexitarian': 'Flexitarian',
    'menu_item_page_food_type_gluten_free': 'Gluten-Free',
    'menu_item_page_food_type_ketogenic': 'Ketogenic (Keto)',
    'menu_item_page_food_type_paleo': 'Paleo',
    'menu_item_page_food_type_low_carb': 'Low-Carb',
    'menu_item_page_food_type_low_fat': 'Low-Fat',
    'menu_item_page_food_type_mediterranean': 'Mediterranean',
    'menu_item_page_food_type_organic': 'Organic',
    'menu_item_page_food_type_processed': 'Processed',
    'menu_item_page_food_type_raw_food': 'Raw Food',
    'menu_item_page_food_type_junk_food': 'Junk Food',
  };

  static const Map<String, String> _measuringUnits = <String, String>{
    'menu_item_page_unit_unit': 'Unit',
    'menu_item_page_unit_piece': 'Piece',
    'menu_item_page_unit_dozen': 'Dozen',
    'menu_item_page_unit_pack': 'Pack',
    'menu_item_page_unit_box': 'Box',
    'menu_item_page_unit_cup': 'Cup',
    'menu_item_page_unit_slice': 'Slice',
    'menu_item_page_unit_can': 'Can',
    'menu_item_page_unit_bottle': 'Bottle',
    'menu_item_page_unit_jar': 'Jar',
    'menu_item_page_unit_bag': 'Bag',
    'menu_item_page_unit_bundle': 'Bundle',
    'menu_item_page_unit_milligram': 'Milligram',
    'menu_item_page_unit_gram': 'Gram',
    'menu_item_page_unit_kilogram': 'Kilogram',
    'menu_item_page_unit_liter': 'Liter',
    'menu_item_page_unit_milliliter': 'Milliliter',
    'menu_item_page_unit_ounce': 'Ounce',
    'menu_item_page_unit_pound': 'Pound',
    'menu_item_page_unit_gallon': 'Gallon',
    'menu_item_page_unit_pint': 'Pint',
    'menu_item_page_unit_quart': 'Quart',
  };

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    final MenuItem? item = widget.item;

    // Initialise controllers
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    String formatDoubleText(double? val) {
      if (val == null) return '';
      return val.toStringAsFixed(2);
    }

    _costPriceController = TextEditingController(
      text: formatDoubleText(item?.costPrice),
    );
    _sellingPriceController = TextEditingController(
      text: formatDoubleText(item?.sellingPrice),
    );

    // Duration
    if (item?.duration != null) {
      _selectedDuration = Duration(seconds: item!.duration!);
    }
    _durationController = TextEditingController(
      text: _formatDuration(_selectedDuration),
    );

    // Selling unit quantity
    final String? initialQty = item?.quantity;
    final String? initialUnit = item?.purchaseUnit;
    if ((initialUnit ?? '').toLowerCase() == 'unit') {
      _sellingUnitQtyController = TextEditingController(
        text: initialQty?.isEmpty ?? true ? '1' : initialQty!,
      );
    } else {
      _sellingUnitQtyController = TextEditingController(text: initialQty ?? '');
    }

    // Focus nodes
    _nameFocusNode = FocusNode(debugLabel: 'dish_name');
    _descriptionFocusNode = FocusNode(debugLabel: 'dish_description');
    _durationFocusNode = FocusNode(debugLabel: 'dish_duration');
    _foodTypeFocusNode = FocusNode(debugLabel: 'food_type');
    _measuringUnitFocusNode = FocusNode(debugLabel: 'measuring_unit');
    _sellingUnitQtyFocusNode = FocusNode(debugLabel: 'selling_unit_qty');
    _costPriceFocusNode = FocusNode(debugLabel: 'cost_price');
    _sellingPriceFocusNode = FocusNode(debugLabel: 'selling_price');

    // Notifiers from item
    if (item != null) {
      _foodTypeNotifier.value = item.foodType;
      _categoryIdNotifier.value = item.categoryId;
      _subcategoryIdNotifier.value = item.subcategoryId;
      _isTodayAvailableNotifier.value = item.isTodayAvailable ?? false;
      _measuringUnitNotifier.value = item.purchaseUnit;
      if (item.isSimpleVariation != null) {
        _isSimpleVariationNotifier.value = item.isSimpleVariation!;
      } else {
        _isSimpleVariationNotifier.value = item.variations.length <= 1;
      }
    }

    // Variations initialization
    if (item != null && item.variations.isNotEmpty) {
      for (final v in item.variations) {
        _variations.add(_VariationFormModel.fromEntity(v));
      }
    } else {
      _variations.add(
        _VariationFormModel(
          unit: item?.purchaseUnit ?? 'Unit',
          quantity: item?.quantity ?? '1',
          costPrice: formatDoubleText(item?.costPrice),
          sellingPrice: formatDoubleText(item?.sellingPrice),
          isTodayAvailable: item?.isTodayAvailable ?? true,
        ),
      );
    }

    // Live profit margin listener
    _costPriceController.addListener(_updateProfitMargin);
    _sellingPriceController.addListener(_updateProfitMargin);
    _updateProfitMargin();
  }

  @override
  void dispose() {
    _costPriceController.removeListener(_updateProfitMargin);
    _sellingPriceController.removeListener(_updateProfitMargin);

    for (final v in _variations) {
      v.dispose();
    }

    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _sellingUnitQtyController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();

    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _durationFocusNode.dispose();
    _foodTypeFocusNode.dispose();
    _measuringUnitFocusNode.dispose();
    _sellingUnitQtyFocusNode.dispose();
    _costPriceFocusNode.dispose();
    _sellingPriceFocusNode.dispose();

    _foodTypeNotifier.dispose();
    _categoryIdNotifier.dispose();
    _subcategoryIdNotifier.dispose();
    _isTodayAvailableNotifier.dispose();
    _measuringUnitNotifier.dispose();
    _profitMarginNotifier.dispose();
    _isSimpleVariationNotifier.dispose();

    super.dispose();
  }

  // ── Duration helpers ──────────────────────────────────────────────────────
  String _formatDuration(Duration duration) {
    final String h = duration.inHours.toString().padLeft(2, '0');
    final String m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final String s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _showDurationPicker() {
    showModalBottomSheet<void>(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext sheetContext) {
        Duration picked = _selectedDuration;
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.35,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.commonCancel,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Cancel',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _selectedDuration = picked;
                        _durationController.text = _formatDuration(
                          _selectedDuration,
                        );
                        Navigator.of(sheetContext).pop();
                      },
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.commonDone,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Done',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  initialTimerDuration: _selectedDuration,
                  onTimerDurationChanged: (Duration d) => picked = d,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Profit margin ─────────────────────────────────────────────────────────
  void _updateProfitMargin() {
    final double cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final double selling = double.tryParse(_sellingPriceController.text) ?? 0.0;
    if (cost == 0.0 || selling == 0.0) {
      _profitMarginNotifier.value = 0.0;
    } else {
      _profitMarginNotifier.value = ((selling - cost) / cost) * 100;
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  void _saveItem() {
    final bool isSimple = _isSimpleVariationNotifier.value;
    final List<MenuItemVariation> variationEntities = isSimple
        ? (_variations.isNotEmpty
              ? <MenuItemVariation>[_variations.first.toEntity()]
              : <MenuItemVariation>[])
        : _variations.map((v) => v.toEntity()).toList();

    final firstVar = _variations.isNotEmpty ? _variations.first : null;
    final costPriceText = firstVar != null
        ? firstVar.costPriceController.text
        : _costPriceController.text;
    final sellingPriceText = firstVar != null
        ? firstVar.sellingPriceController.text
        : _sellingPriceController.text;
    final purchaseUnit = firstVar != null
        ? firstVar.unitNotifier.value
        : _measuringUnitNotifier.value;
    final quantityText = firstVar != null
        ? firstVar.qtyController.text
        : _sellingUnitQtyController.text;
    final isTodayAvailable = firstVar != null
        ? firstVar.isAvailableNotifier.value
        : _isTodayAvailableNotifier.value;

    AddEditMenuItemScreenActions.handleSaveItem(
      context: context,
      formKey: _formKey,
      existingItem: widget.item,
      name: _nameController.text,
      description: _descriptionController.text,
      foodType: _foodTypeNotifier.value,
      categoryId: _categoryIdNotifier.value,
      subcategoryId: _subcategoryIdNotifier.value,
      isTodayAvailable: isTodayAvailable,
      costPriceText: costPriceText,
      sellingPriceText: sellingPriceText,
      purchaseUnit: purchaseUnit,
      quantityText: quantityText,
      selectedDuration: _selectedDuration,
      variations: variationEntities,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.item != null;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            isEdit
                ? context.tr(
                        shared.LocaleKeys.menuItemPageEditMenuItemAppbarTitle,
                        track: shared.TrackConstants.menuItemPageTrack,
                      ) ??
                      'Edit Menu Item'
                : context.tr(
                        shared.LocaleKeys.menuItemPageAddMenuItemAppbarTitle,
                        track: shared.TrackConstants.menuItemPageTrack,
                      ) ??
                      'Add Menu Item',
          ),
          centerTitle: false,
          actions: <Widget>[
            TextButton(
              onPressed: _saveItem,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isEdit
                    ? context.tr(
                            shared.LocaleKeys.menuItemPageAddEditMenuItemUpdate,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Update'
                    : context.tr(
                            shared.LocaleKeys.menuItemPageAddEditMenuItemAdd,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Add',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.menuItemPageAddEditMenuItemName,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Dish Name',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.menuItemPageAddEditMenuItemNameHint,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Enter dish name',
                    errorMaxLines: 3,
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return context.tr(
                            shared
                                .LocaleKeys
                                .menuItemPageAddEditMenuItemPleaseEnterDishName,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Please enter dish name';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    Future.microtask(() {
                      if (!mounted) return;
                      _descriptionFocusNode.requestFocus();
                    });
                  },
                ).inExpandedRow(),
                const SizedBox(height: 12),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared
                              .LocaleKeys
                              .menuItemPageAddEditMenuItemDescription,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Dish Description',
                    hintText:
                        context.tr(
                          shared
                              .LocaleKeys
                              .menuItemPageAddEditMenuItemDescriptionHint,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Enter dish description',
                    errorMaxLines: 3,
                    contentPadding: EdgeInsets.all(20),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return context.tr(
                            shared
                                .LocaleKeys
                                .menuItemPageAddEditMenuItemPleaseEnterDishDescription,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Please enter dish description';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    Future.microtask(() {
                      if (!mounted) return;
                      FocusManager.instance.primaryFocus?.unfocus();
                    });
                  },
                ).inExpandedRow(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  focusNode: _durationFocusNode,
                  readOnly: true,
                  onTap: _showDurationPicker,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared
                              .LocaleKeys
                              .menuItemPageAddEditMenuItemCookingDuration,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Cooking Duration',
                    hintText:
                        context.tr(
                          shared
                              .LocaleKeys
                              .menuItemPageAddEditMenuItemCookingDurationHint,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Select cooking duration (H:M:S) Approx',
                    suffixIcon: const Icon(Icons.timer_outlined),
                  ),
                ).inExpandedRow(),
                const SizedBox(height: 12),
                _buildFoodTypeDropdown().inExpandedRow(),
                const SizedBox(height: 12),
                _buildCategoryDropdown().inExpandedRow(),
                const SizedBox(height: 12),
                _buildSubcategoryDropdown().inExpandedRow(),
                const SizedBox(height: 16),
                _buildVariationsFormSection().inExpandedRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _normalizeFoodType(String? input) {
    if (input == null || input.isEmpty) return null;
    if (_foodTypes.values.contains(input)) return input;
    final lower = input.toLowerCase().trim();
    if (lower == 'non-veg' || lower == 'non_veg' || lower == 'non_vegetarian') {
      return 'Non-Vegetarian';
    }
    if (lower == 'veg' || lower == 'vegetarian') {
      return 'Vegetarian';
    }
    if (lower == 'egg' || lower == 'ovo-vegetarian') {
      return 'Ovo-Vegetarian';
    }
    if (lower == 'vegan') return 'Vegan';

    for (final v in _foodTypes.values) {
      if (v.toLowerCase() == lower) return v;
    }
    return input;
  }

  String? _normalizeMeasuringUnit(String? input) {
    if (input == null || input.isEmpty) return null;
    if (_measuringUnits.values.contains(input)) return input;
    final lower = input.toLowerCase().trim();
    for (final v in _measuringUnits.values) {
      if (v.toLowerCase() == lower) return v;
    }
    return input;
  }

  // ── Food Type Dropdown ─────────────────────────────────────────────────────
  Widget _buildFoodTypeDropdown() {
    return ValueListenableBuilder<String?>(
      valueListenable: _foodTypeNotifier,
      builder: (BuildContext context, String? rawValue, _) {
        final String? value = _normalizeFoodType(rawValue);
        final List<DropdownMenuItem<String>> items = _foodTypes.entries.map((
          MapEntry<String, String> e,
        ) {
          return DropdownMenuItem<String>(
            value: e.value,
            child: Text(
              context.tr(
                    e.key,
                    track: shared.TrackConstants.menuItemPageTrack,
                  ) ??
                  e.value,
            ),
          );
        }).toList();

        if (value != null && !items.any((item) => item.value == value)) {
          items.add(DropdownMenuItem<String>(value: value, child: Text(value)));
        }

        return DropdownButtonFormField<String>(
          menuMaxHeight: MediaQuery.of(context).size.height * 0.35,
          focusNode: _foodTypeFocusNode,
          isDense: true,
          isExpanded: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText:
                context.tr(
                  shared.LocaleKeys.menuItemPageAddEditMenuItemSelectFoodType,
                  track: shared.TrackConstants.menuItemPageTrack,
                ) ??
                'Select Food Type',
            errorMaxLines: 3,
          ),
          initialValue: value,
          onChanged: (String? newValue) {
            _foodTypeNotifier.value = newValue;
          },
          validator: (String? v) {
            if (v == null || v.isEmpty) {
              return context.tr(
                    shared
                        .LocaleKeys
                        .menuItemPageAddEditMenuItemPleaseSelectFoodType,
                    track: shared.TrackConstants.menuItemPageTrack,
                  ) ??
                  'Please select a food type';
            }
            return null;
          },
          items: items,
        );
      },
    );
  }

  // ── Category Dropdown ──────────────────────────────────────────────────────
  Widget _buildCategoryDropdown() {
    return BlocBuilder<MenuCategoryFullListCubit, MenuCategoryFullListState>(
      builder: (BuildContext context, MenuCategoryFullListState state) {
        List<MenuCategory> cats = <MenuCategory>[];
        if (state is MenuCategoryFullListLoadedState) {
          cats =
              context.read<MenuCategoryFullListCubit>().categoryList ??
              <MenuCategory>[];
        }

        if (cats.isEmpty) {
          return Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      AddEditMenuItemScreenActions.handleAddCategory(
                        context,
                        mounted,
                      ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    context.tr(
                          shared.LocaleKeys.menuItemPageAddNewCategory,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Add new category',
                  ),
                ),
              ),
            ],
          );
        }

        return ValueListenableBuilder<int?>(
          valueListenable: _categoryIdNotifier,
          builder: (BuildContext context, int? catId, _) {
            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    menuMaxHeight: MediaQuery.of(context).size.height * 0.35,
                    isDense: true,
                    isExpanded: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText:
                          context.tr(
                            shared
                                .LocaleKeys
                                .menuItemPageAddEditMenuItemCategory,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Select Category',
                      errorMaxLines: 3,
                    ),
                    initialValue: cats.any((c) => c.id == catId) ? catId : null,
                    onChanged: (int? newValue) {
                      _categoryIdNotifier.value = newValue;
                      _subcategoryIdNotifier.value = null;
                    },
                    validator: (int? v) {
                      if (v == null) {
                        return context.tr(
                              shared
                                  .LocaleKeys
                                  .menuItemPageAddEditMenuItemPleaseSelectCategory,
                              track: shared.TrackConstants.menuItemPageTrack,
                            ) ??
                            'Please select a category';
                      }
                      return null;
                    },
                    items: cats.map((MenuCategory c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name ?? ''),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip:
                      context.tr(
                        shared.LocaleKeys.menuItemPageAddNewCategory,
                        track: shared.TrackConstants.menuItemPageTrack,
                      ) ??
                      'Add new category',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () =>
                      AddEditMenuItemScreenActions.handleAddCategory(
                        context,
                        mounted,
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Subcategory Dropdown ───────────────────────────────────────────────────
  Widget _buildSubcategoryDropdown() {
    return BlocBuilder<MenuSubcategoryBloc, MenuSubcategoryState>(
      builder: (BuildContext context, MenuSubcategoryState state) {
        return ValueListenableBuilder<int?>(
          valueListenable: _categoryIdNotifier,
          builder: (BuildContext context, int? catId, _) {
            if (catId == null) {
              return const SizedBox.shrink();
            }

            List<MenuSubcategory> subs = <MenuSubcategory>[];
            if (state is MenuSubcategoryLoaded) {
              subs = state.subcategories
                  .where((MenuSubcategory s) => s.categoryId == catId)
                  .toList();
            }

            if (subs.isEmpty) {
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () =>
                          AddEditMenuItemScreenActions.handleAddSubcategory(
                            context,
                            catId,
                            mounted,
                          ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        context.tr(
                              shared.LocaleKeys.addMenuSubCategoryBtnText,
                              track: shared.TrackConstants.menuCategoryPageTrack,
                            ) ??
                            'Add subcategory',
                      ),
                    ),
                  ),
                ],
              );
            }

            return ValueListenableBuilder<int?>(
              valueListenable: _subcategoryIdNotifier,
              builder: (BuildContext context, int? subId, _) {
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        menuMaxHeight:
                            MediaQuery.of(context).size.height * 0.35,
                        isDense: true,
                        isExpanded: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText:
                              context.tr(
                                shared
                                    .LocaleKeys
                                    .menuItemPageAddEditMenuItemSubCategory,
                                track: shared.TrackConstants.menuItemPageTrack,
                              ) ??
                              'Select Subcategory',
                          errorMaxLines: 3,
                        ),
                        initialValue: subs.any((s) => s.id == subId)
                            ? subId
                            : null,
                        onChanged: (int? newValue) {
                          _subcategoryIdNotifier.value = newValue;
                        },
                        items: subs.map((MenuSubcategory s) {
                          return DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(s.name ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip:
                          context.tr(
                            shared.LocaleKeys
                                .menuItemPageAddNewSubcategoryTooltip,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Add new subcategory',
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () =>
                          AddEditMenuItemScreenActions.handleAddSubcategory(
                            context,
                            catId,
                            mounted,
                          ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ── Variations Section Widget ──────────────────────────────────────────────
  Widget _buildVariationsFormSection() {
    final theme = Theme.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _isSimpleVariationNotifier,
      builder: (context, isSimple, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing & Variations',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            // Segmented Button
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<bool>>[
                  ButtonSegment<bool>(
                    value: true,
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Simple Variation',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    icon: Icon(Icons.sell_outlined, size: 16),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Multiple Variations',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    icon: Icon(Icons.layers_outlined, size: 16),
                  ),
                ],
                selected: <bool>{isSimple},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isSimpleVariationNotifier.value = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isSimple) ...[
              _buildSingleVariationCard(
                v: _variations.isNotEmpty
                    ? _variations.first
                    : _VariationFormModel(unit: 'Unit', quantity: '1'),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Variations (${_variations.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _variations.add(
                          _VariationFormModel(unit: 'Unit', quantity: '1'),
                        );
                      });
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      context.tr(
                            shared.LocaleKeys.menuItemPageVariations,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Add Variation',
                    ),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._variations.asMap().entries.map((entry) {
                final int idx = entry.key;
                final _VariationFormModel v = entry.value;

                return _buildSingleVariationCard(
                  v: v,
                  title: 'Variation #${idx + 1}',
                  showDelete: _variations.length > 1,
                  onDelete: () {
                    setState(() {
                      final removed = _variations.removeAt(idx);
                      removed.dispose();
                    });
                  },
                );
              }),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSingleVariationCard({
    required _VariationFormModel v,
    String? title,
    bool showDelete = false,
    VoidCallback? onDelete,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(120),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || showDelete) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (showDelete)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      tooltip:
                          context.tr(
                            shared.LocaleKeys
                                .menuItemPageRemoveVariationTooltip,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Remove Variation',
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Variation Name (Optional)
            TextFormField(
              controller: v.nameController,
              focusNode: v.nameFocusNode,
              decoration: InputDecoration(
                labelText:
                    'Variation Name (e.g. Small, Medium, Large, Half, Full)',
                hintText:
                    context.tr(
                      shared.LocaleKeys.menuItemPageVariationNameHint,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Enter variation name (optional)',
              ),
            ),
            const SizedBox(height: 12),
            // Selling Unit
            ValueListenableBuilder<String?>(
              valueListenable: v.unitNotifier,
              builder: (context, unit, _) {
                final normalizedUnit = _normalizeMeasuringUnit(unit);
                final items = _measuringUnits.entries.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.value,
                    child: Text(
                      context.tr(
                            e.key,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          e.value,
                    ),
                  );
                }).toList();

                if (normalizedUnit != null &&
                    !items.any((i) => i.value == normalizedUnit)) {
                  items.add(
                    DropdownMenuItem<String>(
                      value: normalizedUnit,
                      child: Text(normalizedUnit),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      menuMaxHeight: MediaQuery.of(context).size.height * 0.35,
                      isDense: true,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared.LocaleKeys.menuItemPageAddEditMenuItemSellingUnit,
                              track: shared.TrackConstants.menuItemPageTrack,
                            ) ??
                            'Selling Unit',
                        hintText:
                            context.tr(
                              shared.LocaleKeys
                                  .menuItemPageAddEditMenuItemSellingUnitHint,
                              track: shared.TrackConstants.menuItemPageTrack,
                            ) ??
                            'Select measuring unit',
                      ),
                      initialValue: normalizedUnit,
                      onChanged: (val) {
                        v.unitNotifier.value = val;
                        v.qtyController.clear();
                      },
                      items: items,
                    ),
                    if (unit != null && unit != 'Unit') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: v.qtyController,
                        focusNode: v.qtyFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,3}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText:
                              context.tr(
                                shared.LocaleKeys
                                    .menuItemPageAddEditMenuItemSellingUnitQuantity,
                                track: shared.TrackConstants.menuItemPageTrack,
                              ) ??
                              'Selling Unit Quantity',
                          hintText:
                              context.tr(
                                shared.LocaleKeys
                                    .menuItemPageAddEditMenuItemSellingUnitQuantityHint,
                                track: shared.TrackConstants.menuItemPageTrack,
                              ) ??
                              'Enter quantity',
                        ),
                        validator: (val) {
                          if (unit != 'Unit') {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter quantity';
                            }
                            final d = double.tryParse(val.trim());
                            if (d == null || d <= 0) {
                              return 'Quantity must be greater than 0';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            // Prices
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: v.costPriceController,
                    focusNode: v.costFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText:
                          context.tr(
                            shared.LocaleKeys.menuItemPageAddEditMenuItemCostPrice,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Cost Price',
                      hintText: '0.00',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Enter cost price';
                      }
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null || parsed < 0) {
                        return 'Enter valid cost price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: v.sellingPriceController,
                    focusNode: v.sellingFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText:
                          context.tr(
                            shared.LocaleKeys.menuItemPageAddEditMenuItemSellingPrice,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          'Selling Price',
                      hintText: '0.00',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Enter selling price';
                      }
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Selling price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Margin & Availability
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: v.profitMarginNotifier,
                  builder: (context, margin, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(
                          120,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Margin: ${margin.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: v.isAvailableNotifier,
                  builder: (context, avail, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr(
                                shared.LocaleKeys.menuItemPageAvailable,
                                track: shared.TrackConstants.menuItemPageTrack,
                              ) ??
                              'Available',
                          style: theme.textTheme.bodySmall,
                        ),
                        Switch.adaptive(
                          value: avail,
                          onChanged: (val) {
                            v.isAvailableNotifier.value = val;
                          },
                          thumbIcon: WidgetStateProperty.resolveWith<Icon>((
                            Set<WidgetState> states,
                          ) {
                            if (states.containsAll(<WidgetState>[
                              WidgetState.disabled,
                              WidgetState.selected,
                            ])) {
                              return const Icon(Icons.check, color: Colors.red);
                            }
                            if (states.contains(WidgetState.disabled)) {
                              return const Icon(Icons.close);
                            }
                            if (states.contains(WidgetState.selected)) {
                              return const Icon(
                                Icons.check,
                                color: Colors.green,
                              );
                            }
                            return const Icon(Icons.close);
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VariationFormModel {
  final int? id;
  final String hashId;
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController costPriceController;
  final TextEditingController sellingPriceController;
  final ValueNotifier<String?> unitNotifier;
  final ValueNotifier<bool> isAvailableNotifier;
  final ValueNotifier<double> profitMarginNotifier;
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode qtyFocusNode = FocusNode();
  final FocusNode costFocusNode = FocusNode();
  final FocusNode sellingFocusNode = FocusNode();

  _VariationFormModel({
    this.id,
    String? hashId,
    String? name,
    String? unit,
    String? quantity,
    String? costPrice,
    String? sellingPrice,
    bool isTodayAvailable = true,
  }) : hashId = hashId ?? const Uuid().v4(),
       nameController = TextEditingController(text: name ?? ''),
       unitNotifier = ValueNotifier(unit ?? 'Unit'),
       qtyController = TextEditingController(text: quantity ?? '1'),
       costPriceController = TextEditingController(text: costPrice ?? ''),
       sellingPriceController = TextEditingController(text: sellingPrice ?? ''),
       isAvailableNotifier = ValueNotifier(isTodayAvailable),
       profitMarginNotifier = ValueNotifier(0.0) {
    costPriceController.addListener(_updateMargin);
    sellingPriceController.addListener(_updateMargin);
    _updateMargin();
  }

  factory _VariationFormModel.fromEntity(MenuItemVariation v) {
    String formatDouble(double? d) {
      if (d == null) return '';
      return d.toStringAsFixed(2);
    }

    return _VariationFormModel(
      id: v.id,
      hashId: v.hashId,
      name: v.name,
      unit: v.purchaseUnit ?? 'Unit',
      quantity: v.quantity != null ? '${v.quantity}' : '1',
      costPrice: formatDouble(v.costPrice),
      sellingPrice: formatDouble(v.sellingPrice),
      isTodayAvailable: v.isTodayAvailable ?? true,
    );
  }

  void _updateMargin() {
    final c = double.tryParse(costPriceController.text) ?? 0.0;
    final s = double.tryParse(sellingPriceController.text) ?? 0.0;
    if (c == 0.0 || s == 0.0) {
      profitMarginNotifier.value = 0.0;
    } else {
      profitMarginNotifier.value = ((s - c) / c) * 100;
    }
  }

  MenuItemVariation toEntity() {
    final rawName = nameController.text.trim();
    return MenuItemVariation(
      id: id,
      hashId: hashId,
      name: rawName.isEmpty ? null : rawName,
      quantity: int.tryParse(qtyController.text),
      purchaseUnit: unitNotifier.value,
      isTodayAvailable: isAvailableNotifier.value,
      costPrice: double.tryParse(costPriceController.text),
      sellingPrice: double.tryParse(sellingPriceController.text),
    );
  }

  void dispose() {
    costPriceController.removeListener(_updateMargin);
    sellingPriceController.removeListener(_updateMargin);
    nameController.dispose();
    qtyController.dispose();
    costPriceController.dispose();
    sellingPriceController.dispose();
    unitNotifier.dispose();
    isAvailableNotifier.dispose();
    profitMarginNotifier.dispose();
    nameFocusNode.dispose();
    qtyFocusNode.dispose();
    costFocusNode.dispose();
    sellingFocusNode.dispose();
  }
}
