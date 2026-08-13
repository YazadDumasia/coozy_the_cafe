import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';

class MenuSubcategoryUpdateDialogActions {
  static void handleCancel(BuildContext context) {
    Navigator.of(context).pop();
  }

  static Future<void> handleUpdate({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required MenuSubcategory currentSubCategory,
    required TextEditingController subCategoryNameController,
    required List<bool> isSelected,
    required Function(MenuSubcategory) onUpdate,
  }) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final String name = subCategoryNameController.text;
      final MenuSubcategory model = currentSubCategory.copyWith(
        name: name,
        isActive: isSelected[0],
      );
      onUpdate(model);
      Navigator.of(context).pop();
    }
  }
}
