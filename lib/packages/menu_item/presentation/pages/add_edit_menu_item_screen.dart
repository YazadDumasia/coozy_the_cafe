import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_edit_menu_item_screen_actions.dart';

import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_state.dart';

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

  // ── Duration ─────────────────────────────────────────────────────────────
  Duration _selectedDuration = Duration.zero;

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
    _costPriceController = TextEditingController(
      text: item?.costPrice?.toString() ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: item?.sellingPrice?.toString() ?? '',
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
    }

    // Live profit margin listener
    _costPriceController.addListener(_updateProfitMargin);
    _sellingPriceController.addListener(_updateProfitMargin);
  }

  @override
  void dispose() {
    _costPriceController.removeListener(_updateProfitMargin);
    _sellingPriceController.removeListener(_updateProfitMargin);

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
              Row(
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
    AddEditMenuItemScreenActions.handleSaveItem(
      context: context,
      formKey: _formKey,
      existingItem: widget.item,
      name: _nameController.text,
      description: _descriptionController.text,
      foodType: _foodTypeNotifier.value,
      categoryId: _categoryIdNotifier.value,
      subcategoryId: _subcategoryIdNotifier.value,
      isTodayAvailable: _isTodayAvailableNotifier.value,
      costPriceText: _costPriceController.text,
      sellingPriceText: _sellingPriceController.text,
      purchaseUnit: _measuringUnitNotifier.value,
      quantityText: _sellingUnitQtyController.text,
      selectedDuration: _selectedDuration,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.item != null;
    return Scaffold(
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
                keyboardType: TextInputType.text,
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
              const SizedBox(height: 12),
              _buildTodayAvailableSwitch().inExpandedRow(),
              const SizedBox(height: 12),
              _buildPricingSection().inExpandedRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Food Type Dropdown ─────────────────────────────────────────────────────
  Widget _buildFoodTypeDropdown() {
    return ValueListenableBuilder<String?>(
      valueListenable: _foodTypeNotifier,
      builder: (BuildContext context, String? value, _) {
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
          items: _foodTypes.entries.map((MapEntry<String, String> e) {
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
          }).toList(),
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
          return ElevatedButton(
            onPressed: () => AddEditMenuItemScreenActions.handleAddCategory(
              context,
              mounted,
            ),
            child: Text(
              context.tr(
                    shared.LocaleKeys.menuItemPageAddNewCategory,
                    track: shared.TrackConstants.menuItemPageTrack,
                  ) ??
                  'Add new category',
            ),
          );
        }

        return ValueListenableBuilder<int?>(
          valueListenable: _categoryIdNotifier,
          builder: (BuildContext context, int? catId, _) {
            return DropdownButtonFormField<int>(
              menuMaxHeight: MediaQuery.of(context).size.height * 0.35,
              isDense: true,
              isExpanded: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.menuItemPageAddEditMenuItemCategory,
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
            List<MenuSubcategory> subs = <MenuSubcategory>[];
            if (state is MenuSubcategoryLoaded && catId != null) {
              subs = state.subcategories
                  .where((MenuSubcategory s) => s.categoryId == catId)
                  .toList();
            }

            if (catId == null || subs.isEmpty) {
              return const SizedBox.shrink();
            }

            return ValueListenableBuilder<int?>(
              valueListenable: _subcategoryIdNotifier,
              builder: (BuildContext context, int? subId, _) {
                return DropdownButtonFormField<int>(
                  menuMaxHeight: MediaQuery.of(context).size.height * 0.35,
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
                  initialValue: subs.any((s) => s.id == subId) ? subId : null,
                  onChanged: (int? newValue) {
                    _subcategoryIdNotifier.value = newValue;
                  },
                  items: subs.map((MenuSubcategory s) {
                    return DropdownMenuItem<int>(
                      value: s.id,
                      child: Text(s.name ?? ''),
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  // ── Today Available Switch ─────────────────────────────────────────────────
  Widget _buildTodayAvailableSwitch() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isTodayAvailableNotifier,
      builder: (BuildContext context, bool value, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.only(left: 10, right: 5),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              title: Text(
                context.tr(
                      shared
                          .LocaleKeys
                          .menuItemPageAddEditMenuItemTodayAvailable,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Today Available',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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
                  return const Icon(Icons.check, color: Colors.green);
                }
                return const Icon(Icons.close);
              }),
              value: value,
              onChanged: (bool newValue) {
                _isTodayAvailableNotifier.value = newValue;
              },
            ),
          ),
        );
      },
    );
  }

  // ── Pricing Section ────────────────────────────────────────────────────────
  Widget _buildPricingSection() {
    return ValueListenableBuilder<String?>(
      valueListenable: _measuringUnitNotifier,
      builder: (BuildContext context, String? unit, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Selling Unit dropdown
            DropdownButtonFormField<String>(
              menuMaxHeight: MediaQuery.of(context).size.height * 0.35,
              focusNode: _measuringUnitFocusNode,
              isDense: true,
              isExpanded: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.menuItemPageAddEditMenuItemSellingUnit,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Selling Unit',
                hintText:
                    context.tr(
                      shared
                          .LocaleKeys
                          .menuItemPageAddEditMenuItemSellingUnitHint,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Select measuring units type',
                errorMaxLines: 3,
              ),
              initialValue: unit,
              onChanged: (String? newValue) {
                _measuringUnitNotifier.value = newValue;
                _sellingUnitQtyController.clear();
              },
              validator: (String? v) {
                if (v == null || v.isEmpty) {
                  return context.tr(
                        shared
                            .LocaleKeys
                            .menuItemPageAddEditMenuItemPleaseSelectMeasuringUnit,
                        track: shared.TrackConstants.menuItemPageTrack,
                      ) ??
                      'Please select a measuring units type';
                }
                return null;
              },
              items: _measuringUnits.entries.map((MapEntry<String, String> e) {
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
              }).toList(),
            ),

            // Selling unit quantity – hidden when 'Unit'
            if (unit != null && unit != 'Unit') ...<Widget>[
              const SizedBox(height: 12),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _sellingUnitQtyController,
                focusNode: _sellingUnitQtyFocusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                ],
                decoration: InputDecoration(
                  labelText:
                      context.tr(
                        shared
                            .LocaleKeys
                            .menuItemPageAddEditMenuItemSellingUnitQuantity,
                        track: shared.TrackConstants.menuItemPageTrack,
                      ) ??
                      'Selling Unit Quantity',
                  hintText:
                      context.tr(
                        shared
                            .LocaleKeys
                            .menuItemPageAddEditMenuItemSellingUnitQuantityHint,
                        track: shared.TrackConstants.menuItemPageTrack,
                      ) ??
                      'Enter value of selling quantity',
                  errorMaxLines: 3,
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return context.tr(
                          shared
                              .LocaleKeys
                              .menuItemPageAddEditMenuItemPleaseEnterSellingUnitValue,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Please enter selling unit value';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  Future.microtask(() {
                    if (!mounted) return;
                    _costPriceFocusNode.requestFocus();
                  });
                },
              ),
            ],

            const SizedBox(height: 12),

            // Cost Price
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _costPriceController,
              focusNode: _costPriceFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
              ],
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.menuItemPageAddEditMenuItemCostPrice,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Cost Price',
                hintText:
                    context.tr(
                      shared
                          .LocaleKeys
                          .menuItemPageAddEditMenuItemCostPriceHint,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Enter value of costing amount',
                errorMaxLines: 3,
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return context.tr(
                        shared
                            .LocaleKeys
                            .menuItemPageAddEditMenuItemPleaseEnterCostAmount,
                        track: shared.TrackConstants.menuItemPageTrack,
                      ) ??
                      'Please enter costing amount';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_sellingPriceFocusNode);
              },
            ),

            const SizedBox(height: 12),

            // Selling Price
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _sellingPriceController,
              focusNode: _sellingPriceFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
              ],
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.menuItemPageAddEditMenuItemSellingPrice,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Selling Price',
                hintText:
                    context.tr(
                      shared
                          .LocaleKeys
                          .menuItemPageAddEditMenuItemSellingPriceHint,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Enter value of selling amount',
                errorMaxLines: 3,
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return context.tr(
                        shared
                            .LocaleKeys
                            .menuItemPageAddEditMenuItemPleaseEnterSellingAmount,
                        track: shared.TrackConstants.menuItemPageTrack,
                      ) ??
                      'Please enter selling amount';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),

            const SizedBox(height: 10),

            // Profit Margin display
            ValueListenableBuilder<double>(
              valueListenable: _profitMarginNotifier,
              builder: (BuildContext context, double margin, _) {
                final Color marginColor = margin < 0
                    ? Colors.red
                    : margin == 0
                    ? Theme.of(context).textTheme.bodyMedium!.color!
                    : Colors.green;
                return RichText(
                  text: TextSpan(
                    text:
                        context.tr(
                          shared
                              .LocaleKeys
                              .menuItemPageAddEditMenuItemProfitMargin,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Profit Margin: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: <TextSpan>[
                      TextSpan(
                        text: '${margin.toStringAsFixed(2)}%',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: marginColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
