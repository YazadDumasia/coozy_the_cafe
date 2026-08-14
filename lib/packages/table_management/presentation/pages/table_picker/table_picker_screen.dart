import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_info.dart';

class TablePickerScreen extends StatefulWidget {
  final Function(TableInfo)? onTableSelected;

  const TablePickerScreen({super.key, this.onTableSelected});

  @override
  State<TablePickerScreen> createState() => _TablePickerScreenState();
}

class _TablePickerScreenState extends State<TablePickerScreen> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(resizeToAvoidBottomInset: true, appBar: AppBar(),),
    );
  }
}
