import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item_variation.dart';

import '../../../domain/entities/combo.dart';
import '../../../domain/entities/combo_item.dart';
import '../../../domain/usecases/combo_usecases.dart';
import 'widget/combo_step_basic_info.dart';
import 'widget/combo_step_select_items.dart';
import 'widget/combo_step_pricing_review.dart';
import 'widget/combo_stepper_nav_buttons.dart';
import 'widget/combo_stepper_headers.dart';
import 'widget/combo_success_celebration_view.dart';

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

  late final TextEditingController _discountPercentController;
  late final FocusNode _discountPercentFocusNode;

  late final TextEditingController _durationController;
  late final FocusNode _durationFocusNode;

  late final ValueNotifier<List<ComboItem>> _selectedItemsNotifier;
  late final ValueNotifier<bool> _isActiveNotifier;
  late final ValueNotifier<bool> _isTotalDurationModeNotifier;
  bool _isDurationManuallyEdited = false;
  bool _isProgrammaticDurationUpdate = false;

  late final PageController _pageController;
  int _currentStep = 0;
  static const int _totalSteps = 3;
  Combo? _savedComboSuccess;

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

    _discountPercentController = TextEditingController();
    _discountPercentFocusNode = FocusNode();

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

    _pageController = PageController(initialPage: 0);
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
    _discountPercentController.dispose();
    _discountPercentFocusNode.dispose();
    _durationController.dispose();
    _durationFocusNode.dispose();
    _selectedItemsNotifier.dispose();
    _isActiveNotifier.dispose();
    _isTotalDurationModeNotifier.dispose();
    _pageController.dispose();
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
      for (final i in items) {
        final d = i.duration;
        if (d != null && d > 0) {
          computedDur += (d * i.quantity);
        }
      }
    } else {
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

  bool _validateCurrentStep(int step) {
    if (step == 0) {
      // Step 0: Validate combo name
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                    shared.LocaleKeys.comboFormDialogNameRequired,
                    track: shared.TrackConstants.comboPageTrack,
                  ) ??
                  'Combo name is required',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        _nameFocusNode.requestFocus();
        return false;
      }
      if (name.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                    shared.LocaleKeys.comboFormDialogNameMinLength,
                    track: shared.TrackConstants.comboPageTrack,
                  ) ??
                  'Name must be at least 2 characters',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        _nameFocusNode.requestFocus();
        return false;
      }
      return true;
    } else if (step == 1) {
      // Step 1: Validate bundle items count (at least 2 items)
      final items = _selectedItemsNotifier.value;
      if (items.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                    shared.LocaleKeys.comboFormDialogItemsMinValidation,
                    track: shared.TrackConstants.comboPageTrack,
                  ) ??
                  'Please select at least 2 items to bundle in this combo.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return false;
      }
      return true;
    }
    return true;
  }

  void _goToStep(int targetIndex) {
    if (targetIndex < 0 || targetIndex >= _totalSteps) return;

    // If moving forward, validate current step first
    if (targetIndex > _currentStep) {
      for (int s = _currentStep; s < targetIndex; s++) {
        if (!_validateCurrentStep(s)) return;
      }
    }

    setState(() {
      _currentStep = targetIndex;
    });

    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_validateCurrentStep(_currentStep)) {
      if (_currentStep < _totalSteps - 1) {
        _goToStep(_currentStep + 1);
      }
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _onSubmit() {
    PlatformUtils.debugLog(ComboFormDialog, '_onSubmit triggered');

    // Run form key validation
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
        SnackBar(
          content: Text(
            context.tr(
                  shared.LocaleKeys.comboFormDialogItemsMinValidation,
                  track: shared.TrackConstants.comboPageTrack,
                ) ??
                'Please select at least 2 items to bundle in this combo.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      _goToStep(1);
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
    setState(() {
      _savedComboSuccess = combo;
    });
  }

  List<ComboStepInfo> _buildStepInfoList(BuildContext context) {
    return [
      ComboStepInfo(
        stepIndex: 0,
        title:
            context.tr(
              shared.LocaleKeys.comboFormDialogStepBasicInfoTitle,
              track: shared.TrackConstants.comboPageTrack,
            ) ??
            'Basic Info',
        subtitle:
            context.tr(
              shared.LocaleKeys.comboFormDialogStepBasicInfoSubtitle,
              track: shared.TrackConstants.comboPageTrack,
            ) ??
            'Name & general details',
        icon: Icons.info_outline_rounded,
      ),
      ComboStepInfo(
        stepIndex: 1,
        title:
            context.tr(
              shared.LocaleKeys.comboFormDialogStepSelectItemsTitle,
              track: shared.TrackConstants.comboPageTrack,
            ) ??
            'Select Items',
        subtitle:
            context.tr(
              shared.LocaleKeys.comboFormDialogStepSelectItemsSubtitle,
              track: shared.TrackConstants.comboPageTrack,
            ) ??
            'Bundle 2 or more dishes',
        icon: Icons.restaurant_menu_rounded,
      ),
      ComboStepInfo(
        stepIndex: 2,
        title:
            context.tr(
              shared.LocaleKeys.comboFormDialogStepPricingReviewTitle,
              track: shared.TrackConstants.comboPageTrack,
            ) ??
            'Pricing & Review',
        subtitle:
            context.tr(
              shared.LocaleKeys.comboFormDialogStepPricingReviewSubtitle,
              track: shared.TrackConstants.comboPageTrack,
            ) ??
            'Special price & duration',
        icon: Icons.price_check_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);
    final isMobile = shared.ResponsiveLayout.isMobile(context);

    final steps = _buildStepInfoList(context);

    final String dialogTitle = widget.initialCombo == null
        ? (context.tr(
                shared.LocaleKeys.comboFormDialogCreateTitle,
                track: shared.TrackConstants.comboPageTrack,
              ) ??
              'Create Combo / Bundle')
        : (context.tr(
                shared.LocaleKeys.comboFormDialogEditTitle,
                track: shared.TrackConstants.comboPageTrack,
              ) ??
              'Edit Combo / Bundle');

    final isFullScreen = isMobile || isTablet;

    if (_savedComboSuccess != null) {
      final successWidget = ComboSuccessCelebrationView(
        combo: _savedComboSuccess!,
        isEditMode: widget.initialCombo != null,
        onDone: () => Navigator.of(context).pop(),
      );

      if (isFullScreen) {
        return Dialog.fullscreen(
          child: Scaffold(body: SafeArea(child: successWidget)),
        );
      }

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 620,
            maxHeight: screenSize.height * 0.85,
          ),
          child: Scaffold(body: SafeArea(child: successWidget)),
        ),
      );
    }

    if (isFullScreen) {
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              dialogTitle,
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
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.tr(
                        shared.LocaleKeys.commonCancel,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Cancel',
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                if (isTablet)
                  TabletSegmentedStepper(
                    activeIndex: _currentStep,
                    steps: steps,
                    onStepTapped: _goToStep,
                  )
                else
                  MobileIconStepper(
                    activeIndex: _currentStep,
                    steps: steps,
                    onStepTapped: _goToStep,
                  ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) {
                      setState(() {
                        _currentStep = idx;
                      });
                    },
                    children: [
                      ComboStepBasicInfo(
                        nameController: _nameController,
                        nameFocusNode: _nameFocusNode,
                        descriptionController: _descriptionController,
                        descriptionFocusNode: _descriptionFocusNode,
                        isActiveNotifier: _isActiveNotifier,
                      ),
                      ComboStepSelectItems(
                        searchUseCase: widget.searchUseCase,
                        countUseCase: widget.countUseCase,
                        selectedItemsNotifier: _selectedItemsNotifier,
                        onMenuItemSelected: _onMenuItemSelected,
                        onQuantityChanged: _onQuantityChanged,
                        onRemoveItem: _onRemoveItem,
                      ),
                      ComboStepPricingReview(
                        sellingPriceController: _sellingPriceController,
                        sellingPriceFocusNode: _sellingPriceFocusNode,
                        discountPercentController: _discountPercentController,
                        discountPercentFocusNode: _discountPercentFocusNode,
                        durationController: _durationController,
                        durationFocusNode: _durationFocusNode,
                        selectedItemsNotifier: _selectedItemsNotifier,
                        isTotalDurationModeNotifier:
                            _isTotalDurationModeNotifier,
                        onRecalculateDuration: () =>
                            _recalculateDuration(_selectedItemsNotifier.value),
                        onQuantityChanged: _onQuantityChanged,
                        onRemoveItem: _onRemoveItem,
                      ),
                    ],
                  ),
                ),
                ComboStepperNavButtons(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                  onBack: _onBack,
                  onNext: _onNext,
                  onSubmit: _onSubmit,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Web / Desktop modal dialog: Centered popup card as shown in reference Image 2
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1120,
          maxHeight: screenSize.height * 0.88,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              dialogTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.tr(
                        shared.LocaleKeys.commonCancel,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Cancel',
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left sidebar: Web Stepper
                SizedBox(
                  width: 320,
                  child: WebStepperSidebar(
                    activeIndex: _currentStep,
                    steps: steps,
                    onStepTapped: _goToStep,
                    isEditMode: widget.initialCombo != null,
                  ),
                ),
                // Right side: Active form step content + bottom nav
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (idx) {
                            setState(() {
                              _currentStep = idx;
                            });
                          },
                          children: [
                            ComboStepBasicInfo(
                              nameController: _nameController,
                              nameFocusNode: _nameFocusNode,
                              descriptionController: _descriptionController,
                              descriptionFocusNode: _descriptionFocusNode,
                              isActiveNotifier: _isActiveNotifier,
                            ),
                            ComboStepSelectItems(
                              searchUseCase: widget.searchUseCase,
                              countUseCase: widget.countUseCase,
                              selectedItemsNotifier: _selectedItemsNotifier,
                              onMenuItemSelected: _onMenuItemSelected,
                              onQuantityChanged: _onQuantityChanged,
                              onRemoveItem: _onRemoveItem,
                            ),
                            ComboStepPricingReview(
                              sellingPriceController: _sellingPriceController,
                              sellingPriceFocusNode: _sellingPriceFocusNode,
                              discountPercentController:
                                  _discountPercentController,
                              discountPercentFocusNode:
                                  _discountPercentFocusNode,
                              durationController: _durationController,
                              durationFocusNode: _durationFocusNode,
                              selectedItemsNotifier: _selectedItemsNotifier,
                              isTotalDurationModeNotifier:
                                  _isTotalDurationModeNotifier,
                              onRecalculateDuration: () => _recalculateDuration(
                                _selectedItemsNotifier.value,
                              ),
                              onQuantityChanged: _onQuantityChanged,
                              onRemoveItem: _onRemoveItem,
                            ),
                          ],
                        ),
                      ),
                      ComboStepperNavButtons(
                        currentStep: _currentStep,
                        totalSteps: _totalSteps,
                        onBack: _onBack,
                        onNext: _onNext,
                        onSubmit: _onSubmit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
