import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'add_edit_inventory_screen_actions.dart';

class AddEditInventoryScreen extends StatefulWidget {
  final InventoryItem? item;
  const AddEditInventoryScreen({super.key, this.item});

  @override
  State<AddEditInventoryScreen> createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _shortDescription;
  late String _purchaseUnit;
  late double _currentStock;
  late final ValueNotifier<bool> _isEnabledNotifier;

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
            TextFormField(
              controller: _purchaseUnitController,
              focusNode: _purchaseUnitFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _currentStockFocusNode.requestFocus(),
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.inventoryAddEditDailogPurchaseUnit,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Purchase Unit',
                hintText:
                    context.tr(
                      shared.LocaleKeys.inventoryAddEditDailogPurchaseUnitHint,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    '(e.g., kg, L, pieces)',
              ),
              validator: (val) => val == null || val.isEmpty
                  ? context.tr(
                          shared.LocaleKeys.commonRequired,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Required'
                  : null,
              onSaved: (val) => _purchaseUnit = val!,
            ).inExpandedRow(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentStockController,
              focusNode: _currentStockFocusNode,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _currentStockFocusNode.unfocus(),
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.inventoryAddEditDailogCurrentStock,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Current Stock',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (val) {
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
              onSaved: (val) => _currentStock = double.parse(val!),
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
