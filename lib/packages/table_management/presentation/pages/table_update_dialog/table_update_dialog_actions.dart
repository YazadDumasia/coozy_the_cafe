import 'package:flutter/material.dart';
import '../../../domain/entities/table_info.dart';

class TableUpdateDialogActions {
  static void onCancel(BuildContext context) {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  static void onUpdate(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController tableNameController,
    TextEditingController tableNoController,
    TextEditingController hexColorTextEditingController,
    TextEditingController nosOfChairsController,
    TableInfo table,
    Function(TableInfo)? onUpdateCallback,
  ) {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final String tableLabel = tableNameController.text;
      final String tableNo = tableNoController.text;
      final String color = hexColorTextEditingController.text;
      final int? nosOfChairs = int.tryParse(
        nosOfChairsController.text.toString(),
      );
      final TableInfo updatedTableInfo = TableInfo(
        id: table.id,
        tableLabel: tableLabel,
        tableNo: tableNo,
        nosOfChairs: nosOfChairs ?? 4,
        colorValue: color,
        sortOrderIndex: table.sortOrderIndex,
      );
      if (onUpdateCallback != null) {
        onUpdateCallback(updatedTableInfo);
      } else {
        if (context.mounted) {
          Navigator.pop(context, updatedTableInfo);
        }
      }
    }
  }
}
