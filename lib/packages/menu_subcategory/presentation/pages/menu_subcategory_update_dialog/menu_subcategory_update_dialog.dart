import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'menu_subcategory_update_dialog_actions.dart';

class MenuSubcategoryUpdateDialog extends StatefulWidget {
  const MenuSubcategoryUpdateDialog({
    required this.currentSubCategory,
    required this.onUpdate,
    super.key,
  });
  final MenuSubcategory currentSubCategory;
  final Function(MenuSubcategory) onUpdate;

  @override
  State<MenuSubcategoryUpdateDialog> createState() =>
      _MenuSubcategoryUpdateDialogState();
}

class _MenuSubcategoryUpdateDialogState
    extends State<MenuSubcategoryUpdateDialog> {
  TextEditingController? _subCategoryNameController;
  FocusNode? _subCategoryNameFocusNode;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<List<bool>> _isSelectedNotifier =
      ValueNotifier<List<bool>>(<bool>[false, true]);

  @override
  void initState() {
    super.initState();
    _subCategoryNameController = TextEditingController(
      text: widget.currentSubCategory.name,
    );
    _subCategoryNameFocusNode = FocusNode();
    _isSelectedNotifier.value = widget.currentSubCategory.isActive == true
        ? <bool>[true, false]
        : <bool>[false, true];
  }

  @override
  void dispose() {
    _subCategoryNameController?.dispose();
    _subCategoryNameFocusNode?.dispose();
    _isSelectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Update Sub-category',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _subCategoryNameController,
                    focusNode: _subCategoryNameFocusNode,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelText:
                          context.tr(
                            shared.LocaleKeys.addNewMenuSubCategoryLabelText,
                            track:
                                shared.TrackConstants.menuSubCategoryPageTrack,
                          ) ??
                          'Sub-category Name',
                      hintText:
                          context.tr(
                            shared.LocaleKeys.addNewMenuSubCategoryHintText,
                            track:
                                shared.TrackConstants.menuSubCategoryPageTrack,
                          ) ??
                          'Enter sub-category name',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.tr(
                              shared.LocaleKeys.addNewMenuSubCategoryErrorText,
                              track: shared
                                  .TrackConstants
                                  .menuSubCategoryPageTrack,
                            ) ??
                            'Sub-category name is required.';
                      } else {
                        return null;
                      }
                    },
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Is Active:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: ValueListenableBuilder<List<bool>>(
                    valueListenable: _isSelectedNotifier,
                    builder: (context, isSelected, _) {
                      return ToggleButtons(
                        isSelected: isSelected,
                        onPressed: (int index) {
                          final List<bool> newSelection = List<bool>.from(
                            isSelected,
                          );
                          for (
                            int buttonIndex = 0;
                            buttonIndex < newSelection.length;
                            buttonIndex++
                          ) {
                            newSelection[buttonIndex] = buttonIndex == index;
                          }
                          _isSelectedNotifier.value = newSelection;
                        },
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        renderBorder: true,
                        borderColor: Theme.of(context).colorScheme.primary,
                        selectedBorderColor: Theme.of(
                          context,
                        ).colorScheme.primary,
                        borderWidth: 1,
                        constraints: const BoxConstraints(
                          minHeight: 30,
                          maxHeight: 30,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        borderRadius: BorderRadius.circular(10),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              context.tr(
                                    shared.LocaleKeys.commonActive,
                                    track: shared.TrackConstants.commonTrack,
                                  ) ??
                                  'Active',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              context.tr(
                                    shared.LocaleKeys.deactivate,
                                    track: shared.TrackConstants.commonTrack,
                                  ) ??
                                  'Deactivate',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () =>
              MenuSubcategoryUpdateDialogActions.handleCancel(context),
          child: Text(
            context.tr(
                  shared.LocaleKeys.commonCancel,
                  track: shared.TrackConstants.menuSubCategoryPageTrack,
                ) ??
                'Cancel',
          ),
        ),
        TextButton(
          onPressed: () => MenuSubcategoryUpdateDialogActions.handleUpdate(
            context: context,
            formKey: _formKey,
            currentSubCategory: widget.currentSubCategory,
            subCategoryNameController: _subCategoryNameController!,
            isSelected: _isSelectedNotifier.value,
            onUpdate: widget.onUpdate,
          ),
          child: Text(
            context.tr(
                  shared.LocaleKeys.commonUpdate,
                  track: shared.TrackConstants.menuSubCategoryPageTrack,
                ) ??
                'Update',
          ),
        ),
      ],
    );
  }
}
