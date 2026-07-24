import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/table_info.dart';

class NewTableInfoDialogActions {
  static void onCancel(BuildContext context) {
    if (context.mounted && context.canPop()) {
      context.pop();
    }
  }

  static void onSubmit(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController tableNameController,
    TextEditingController hexColorTextEditingController,
    TextEditingController nosOfChairsController,
    Function(TableInfo)? onCreate,
  ) {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final String tableName = tableNameController.text;
      final String color = hexColorTextEditingController.text;

      final int? nosOfChairs = int.tryParse(
        nosOfChairsController.text.toString(),
      );
      final TableInfo tableInfoModel = TableInfo(
        name: tableName,
        nosOfChairs: nosOfChairs ?? 4,
        colorValue: color,
      );
      if (onCreate != null) {
        onCreate(tableInfoModel);
      } else {
        if (context.mounted && context.canPop()) {
          context.pop(tableInfoModel);
        }
      }
    }
  }
}
