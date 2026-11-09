import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/inventory/domain/entities/measuring_unit.dart';

import 'add_edit_inventory_screen_actions.dart';

class AddEditInventoryScreen extends StatefulWidget {
  final InventoryItem? item;
  const AddEditInventoryScreen({super.key, this.item});

  @override
  State<AddEditInventoryScreen> createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();

  static const String _customUnitOption = 'Custom...';

  late String _name;
  late String _shortDescription;
  late String _purchaseUnit;
  late double _currentStock;
  late final ValueNotifier<bool> _isEnabledNotifier;
  late final ValueNotifier<String?> _selectedUnitNotifier;

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _shortDescriptionController;
  late final TextEditingController _purchaseUnitController;
  late final TextEditingController _currentStockController;

  // FocusNodes
  late final FocusNode _nameFocusNode;
  late final FocusNode _shortDescriptionFocusNode;
  late final FocusNode _purchaseUnitFocusNode;
  late final FocusNode _currentStockFocusNode;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _name = widget.item!.name ?? '';
      _shortDescription = widget.item!.shortDescription ?? '';
      _purchaseUnit = widget.item!.purchaseUnit ?? '';
      _currentStock = widget.item!.currentStock ?? 0.0;
      _isEnabledNotifier = ValueNotifier(widget.item!.isEnabled ?? true);
    } else {
      _name = '';
      _shortDescription = '';
      _purchaseUnit = '';
      _currentStock = 0.0;
      _isEnabledNotifier = ValueNotifier(true);
    }

    // Determine initial dropdown selection
    String? initialUnit;
    if (_purchaseUnit.isNotEmpty) {
      final unit = MeasuringUnit.fromString(_purchaseUnit);
      if (unit != null) {
        initialUnit = unit.name;
        _purchaseUnit = unit.name;
      } else {
        initialUnit = _customUnitOption;
      }
    }
    _selectedUnitNotifier = ValueNotifier<String?>(initialUnit);

    // Initialize controllers with existing values
    _nameController = TextEditingController(text: _name);
    _shortDescriptionController = TextEditingController(
      text: _shortDescription,
    );
    _purchaseUnitController = TextEditingController(text: _purchaseUnit);
    _currentStockController = TextEditingController(
      text: _currentStock == 0.0 ? '' : _currentStock.toString(),
    );

    // Initialize focus nodes
    _nameFocusNode = FocusNode();
    _shortDescriptionFocusNode = FocusNode();
    _purchaseUnitFocusNode = FocusNode();
    _currentStockFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _purchaseUnitController.dispose();
    _currentStockController.dispose();

    // Dispose focus nodes
    _nameFocusNode.dispose();
    _shortDescriptionFocusNode.dispose();
    _purchaseUnitFocusNode.dispose();
    _currentStockFocusNode.dispose();

    _isEnabledNotifier.dispose();
    _selectedUnitNotifier.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      AddEditInventoryScreenActions.saveItem(
        context: context,
        existingItem: widget.item,
        name: _nameController.text.trim(),
        shortDescription: _shortDescriptionController.text.trim(),
        purchaseUnit: _purchaseUnitController.text.trim(),
        currentStock:
            double.tryParse(_currentStockController.text.trim()) ?? 0.0,
        isEnabled: _isEnabledNotifier.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            widget.item == null
                ? context.tr(
                        shared.LocaleKeys.inventoryAddEditDailogAddTitle,
                        track: shared.TrackConstants.inventoryPageTrack,
                      ) ??
                      'Add Inventory Item'
                : context.tr(
                        shared.LocaleKeys.inventoryAddEditDailogEditTitle,
                        track: shared.TrackConstants.inventoryPageTrack,
                      ) ??
                      'Edit Inventory Item',
          ),
          actions: [
            IconButton(icon: const Icon(Icons.check), onPressed: _saveItem),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  _shortDescriptionFocusNode.requestFocus(),
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.inventoryAddEditDailogItemName,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Item Name',
              ),
              validator: (val) => val == null || val.isEmpty
                  ? context.tr(
                          shared.LocaleKeys.commonRequired,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Required'
                  : null,
              onSaved: (val) => _name = val!,
            ).inExpandedRow(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shortDescriptionController,
              focusNode: _shortDescriptionFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _purchaseUnitFocusNode.requestFocus(),
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.inventoryAddEditDailogItemDescription,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Description',
              ),
              onSaved: (val) => _shortDescription = val ?? '',
            ).inExpandedRow(),
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: _selectedUnitNotifier,
              builder: (context, selectedUnit, _) {
                final List<DropdownMenuItem<String>> dropdownItems =
                    MeasuringUnit.values.map((unit) {
                      final localizedLabel =
                          context.tr(
                            unit.localeKey,
                            track: shared.TrackConstants.menuItemPageTrack,
                          ) ??
                          unit.name;
                      return DropdownMenuItem<String>(
                        value: unit.name,
                        child: Text(localizedLabel),
                      );
                    }).toList();

                dropdownItems.add(
                  DropdownMenuItem<String>(
                    value: _customUnitOption,
                    child: Text(
                      _customUnitOption,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                );

                if (selectedUnit != null &&
                    selectedUnit.isNotEmpty &&
                    selectedUnit != _customUnitOption &&
                    !dropdownItems.any((item) => item.value == selectedUnit)) {
                  dropdownItems.insert(
                    dropdownItems.length - 1,
                    DropdownMenuItem<String>(
                      value: selectedUnit,
                      child: Text(selectedUnit),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue:
                          dropdownItems.any((i) => i.value == selectedUnit)
                          ? selectedUnit
                          : (selectedUnit == _customUnitOption
                                ? _customUnitOption
                                : null),
                      focusNode: _purchaseUnitFocusNode,
                      isDense: true,
                      isExpanded: true,
                      menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared
                                  .LocaleKeys
                                  .inventoryAddEditDailogPurchaseUnit,
                              track: shared.TrackConstants.inventoryPageTrack,
                            ) ??
                            'Purchase Unit',
                        hintText:
                            context.tr(
                              shared
                                  .LocaleKeys
                                  .inventoryAddEditDailogPurchaseUnitHint,
                              track: shared.TrackConstants.inventoryPageTrack,
                            ) ??
                            'Select Purchase Unit (e.g., kg, L, pieces)',
                      ),
                      items: dropdownItems,
                      onChanged: (val) {
                        _selectedUnitNotifier.value = val;
                        if (val != null && val != _customUnitOption) {
                          _purchaseUnitController.text = val;
                        } else if (val == _customUnitOption) {
                          _purchaseUnitController.clear();
                        }
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return context.tr(
                                shared.LocaleKeys.commonRequired,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Required';
                        }
                        if (val == _customUnitOption &&
                            _purchaseUnitController.text.trim().isEmpty) {
                          return context.tr(
                                shared.LocaleKeys.commonRequired,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Please enter a custom unit';
                        }
                        return null;
                      },
                    ),
                    if (selectedUnit == _customUnitOption) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _purchaseUnitController,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _currentStockFocusNode.requestFocus(),
                        decoration: InputDecoration(
                          labelText: 'Custom Purchase Unit',
                          hintText: 'Enter unit (e.g. carton, barrel, crate)',
                          prefixIcon: const Icon(Icons.edit_outlined),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? context.tr(
                                    shared.LocaleKeys.commonRequired,
                                    track: shared.TrackConstants.commonTrack,
                                  ) ??
                                  'Required'
                            : null,
                        onSaved: (val) => _purchaseUnit = val?.trim() ?? '',
                      ),
                    ],
                  ],
                );
              },
            ).inExpandedRow(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentStockController,
              focusNode: _currentStockFocusNode,
              enabled: widget.item == null,
              readOnly: widget.item != null,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _currentStockFocusNode.unfocus(),
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.inventoryAddEditDailogCurrentStock,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Current Stock',
                helperText: widget.item != null
                    ? (context.tr(
                            shared
                                .LocaleKeys
                                .inventoryAddEditDailogCurrentStockDisabledHint,
                            track: shared.TrackConstants.inventoryPageTrack,
                          ) ??
                          "Stock cannot be edited directly. Use 'Adjust Stock' from the menu.")
                    : null,
                helperMaxLines: 2,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (val) {
                if (widget.item != null) {
                  return null;
                }
                if (val == null || val.isEmpty) {
                  return context.tr(
                        shared.LocaleKeys.commonRequired,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Required';
                } else if (double.tryParse(val) == null) {
                  return context.tr(
                        shared.LocaleKeys.inventoryAddEditDailogMustBeNumber,
                        track: shared.TrackConstants.inventoryPageTrack,
                      ) ??
                      'Must be a number';
                }
                return null;
              },
              onSaved: (val) => _currentStock =
                  double.tryParse(val ?? '') ??
                  (widget.item?.currentStock ?? 0.0),
            ).inExpandedRow(),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _isEnabledNotifier,
              builder: (context, isEnabled, child) {
                return InputDecorator(
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr(
                              shared.LocaleKeys.inventoryAddEditDailogIsEnabled,
                              track: shared.TrackConstants.inventoryPageTrack,
                            ) ??
                            'Is Enabled',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Switch(
                        value: isEnabled,
                        thumbIcon: WidgetStateProperty.resolveWith<Icon>((
                          Set<WidgetState> states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return const Icon(Icons.check, color: Colors.green);
                          }
                          return const Icon(Icons.close, color: Colors.red);
                        }),
                        onChanged: (val) {
                          _isEnabledNotifier.value = val;
                        },
                      ),
                    ],
                  ),
                );
              },
            ).inExpandedRow(),
          ],
        ),
      ),
    );
  }
}
