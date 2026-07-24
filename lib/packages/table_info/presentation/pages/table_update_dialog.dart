import 'package:coozy_the_cafe/packages/shared/config/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    hide UpperCaseTextFormatter;
import '../../../shared/coozy_shared.dart' as shared;
import '../../domain/entities/table_info.dart';
import 'table_update_dialog_actions.dart';

class TableUpdateDialog extends StatefulWidget {
  final TableInfo table;
  final Function(TableInfo)? onUpdate;

  const TableUpdateDialog({required this.table, this.onUpdate, super.key});

  @override
  State<TableUpdateDialog> createState() => TableUpdateDialogState();
}

class TableUpdateDialogState extends State<TableUpdateDialog> {
  TextEditingController? _tableNameController;
  FocusNode? _tableNameFocusNode;
  TextEditingController? _nosOfChairsController;
  FocusNode? _nosOfChairsFocusNode;

  late TextEditingController _hexColorTextEditingController;
  FocusNode? _hexColorFocusNode;
  final ValueNotifier<Color> _selectedColorNotifier = ValueNotifier<Color>(
    Colors.white,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onHexColorChanged() {
    String text = _hexColorTextEditingController.text.toUpperCase().replaceAll(
      '#',
      '',
    );
    if (text.length == 6 || text.length == 8) {
      if (text.length == 6) {
        text = 'FF$text';
      }
      final int? hexValue = int.tryParse(text, radix: 16);
      if (hexValue != null) {
        final Color newColor = Color(hexValue);
        if (_selectedColorNotifier.value != newColor) {
          _selectedColorNotifier.value = newColor;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tableNameController = TextEditingController(text: widget.table.name);
    _tableNameFocusNode = FocusNode();
    _nosOfChairsFocusNode = FocusNode();
    _nosOfChairsController = TextEditingController(
      text: '${widget.table.nosOfChairs}',
    );
    _hexColorTextEditingController = TextEditingController(
      text: '${widget.table.colorValue}',
    );
    _hexColorTextEditingController.addListener(_onHexColorChanged);
    _hexColorFocusNode = FocusNode();
    _selectedColorNotifier.value = Color(
      int.parse(widget.table.colorValue ?? 'FFFFFF', radix: 16) | 0xFF000000,
    );
  }

  @override
  void dispose() {
    _hexColorTextEditingController.removeListener(_onHexColorChanged);
    _selectedColorNotifier.dispose();
    _tableNameController?.dispose();
    _tableNameFocusNode?.dispose();
    _nosOfChairsController?.dispose();
    _nosOfChairsFocusNode?.dispose();
    _hexColorTextEditingController.dispose();
    _hexColorFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.tr(
              shared.LocaleKeys.tableUpdateTitle,
              track: shared.TrackConstants.tablePageTrack,
            ) ??
            'Update Table Name',
      ),
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _tableNameController,
                      focusNode: _tableNameFocusNode,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText:
                            context.tr(
                              shared.LocaleKeys.tableNameLabelText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Table Name',
                        hintText:
                            context.tr(
                              shared.LocaleKeys.tableNameHintText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Enter table name like Table1',
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr(
                                shared.LocaleKeys.tableNameErrorText,
                                track: shared.TrackConstants.tablePageTrack,
                              ) ??
                              'Table name is required.';
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (String value) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_nosOfChairsFocusNode);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      focusNode: _nosOfChairsFocusNode,
                      controller: _nosOfChairsController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText:
                            context.tr(
                              shared.LocaleKeys.tableNosOfChairsLabelText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Nos Of Chairs per Table',
                        hintText:
                            context.tr(
                              shared.LocaleKeys.tableNosOfChairsHintText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Enter number of chairs',
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onFieldSubmitted: (String value) {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ValueListenableBuilder<Color>(
                  valueListenable: _selectedColorNotifier,
                  builder: (context, value, child) {
                    return ColorPicker(
                      pickerColor: value,
                      onColorChanged: (Color color) {
                        _selectedColorNotifier.value = color;
                      },
                      enableAlpha: true,
                      pickerAreaHeightPercent: 0.35,
                      hexInputController: _hexColorTextEditingController,
                      paletteType: PaletteType.hsvWithHue,
                      displayThumbColor: true,
                      portraitOnly: true,
                      labelTypes: const <ColorLabelType>[],
                    );
                  },
                ),
              ).inExpandedRow(),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      focusNode: _hexColorFocusNode,
                      controller: _hexColorTextEditingController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared.LocaleKeys.colorIndicatorTableLabelText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Color Indicator for Table',
                        hintText:
                            context.tr(
                              shared.LocaleKeys.colorIndicatorTableHintText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Select an unique color',
                      ),
                      inputFormatters: <TextInputFormatter>[
                        shared.UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(
                          RegExp(kValidHexPattern),
                        ),
                      ],
                      maxLength: 9,
                      onFieldSubmitted: (String value) {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            TableUpdateDialogActions.onCancel(context);
          },
          child: Text(
            context.tr(
                  shared.LocaleKeys.commonCancel,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'cancel',
          ),
        ),
        TextButton(
          onPressed: () {
            TableUpdateDialogActions.onUpdate(
              context,
              _formKey,
              _tableNameController!,
              _hexColorTextEditingController,
              _nosOfChairsController!,
              widget.table,
              widget.onUpdate,
            );
          },
          child: Text(
            context.tr(
                  shared.LocaleKeys.commonUpdate,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Update',
          ),
        ),
      ],
    );
  }
}
