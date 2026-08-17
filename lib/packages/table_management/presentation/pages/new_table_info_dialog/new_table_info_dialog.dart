import 'package:coozy_the_cafe/packages/shared/config/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    hide UpperCaseTextFormatter;
import '../../../../shared/coozy_shared.dart' as shared;
import '../../../domain/entities/table_info.dart';
import 'new_table_info_dialog_actions.dart';

class NewTableInfoDialog extends StatefulWidget {
  final Function(TableInfo)? onCreate;
  const NewTableInfoDialog({super.key, this.onCreate});

  @override
  State<NewTableInfoDialog> createState() => NewTableInfoDialogState();
}

class NewTableInfoDialogState extends State<NewTableInfoDialog> {
  late TextEditingController _tableNameController;
  FocusNode? _tableNameFocusNode;
  late TextEditingController _tableNoController;
  FocusNode? _tableNoFocusNode;
  late TextEditingController _nosOfChairsController;
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
    _hexColorTextEditingController = TextEditingController(text: 'FFFFFFFF');
    _hexColorTextEditingController.addListener(_onHexColorChanged);
    _hexColorFocusNode = FocusNode();
    _tableNameController = TextEditingController(text: '');
    _tableNameFocusNode = FocusNode();
    _tableNoController = TextEditingController(text: '');
    _tableNoFocusNode = FocusNode();
    _nosOfChairsFocusNode = FocusNode();
    _nosOfChairsController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _hexColorTextEditingController.removeListener(_onHexColorChanged);
    _selectedColorNotifier.dispose();
    _hexColorTextEditingController.dispose();
    _hexColorFocusNode?.dispose();
    _tableNameController.dispose();
    _tableNameFocusNode?.dispose();
    _tableNoController.dispose();
    _tableNoFocusNode?.dispose();
    _nosOfChairsController.dispose();
    _nosOfChairsFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ), // Adjust the value to reduce roundness
      ),
      titlePadding: EdgeInsets.only(top: 10, bottom: 0, right: 24, left: 24),
      actionsPadding: EdgeInsets.only(
        bottom: 10,
        top: 10.0,
        right: 10,
        left: 10.0,
      ),
      title: Text(
        context.tr(
              shared.LocaleKeys.addNewTableTitle,
              track: shared.TrackConstants.tablePageTrack,
            ) ??
            'Create New Table',
      ),
      content: Form(
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
                      labelText:
                          context.tr(
                            shared.LocaleKeys.tableNameLabelText,
                            track: shared.TrackConstants.tablePageTrack,
                          ) ??
                          'Table Label',
                      hintText:
                          context.tr(
                            shared.LocaleKeys.tableNameHintText,
                            track: shared.TrackConstants.tablePageTrack,
                          ) ??
                          'Enter table label like Table1',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.tr(
                              shared.LocaleKeys.tableNameErrorText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Table label is required.';
                      } else {
                        return null;
                      }
                    },
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context).requestFocus(_tableNoFocusNode);
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
                    controller: _tableNoController,
                    focusNode: _tableNoFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Table No',
                      hintText: 'Enter table number e.g. T-1',
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
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
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
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
                      FocusScope.of(context).requestFocus(_hexColorFocusNode);
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
                builder: (context, colorValue, child) {
                  return ColorPicker(
                    pickerColor: colorValue,
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
      actions: <Widget>[
        TextButton(
          onPressed: () {
            NewTableInfoDialogActions.onCancel(context);
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
            NewTableInfoDialogActions.onSubmit(
              context,
              _formKey,
              _tableNameController,
              _tableNoController,
              _hexColorTextEditingController,
              _nosOfChairsController,
              widget.onCreate,
            );
          },
          child: Text(
            context.tr(
                  shared.LocaleKeys.commonSubmit,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Submit',
          ),
        ),
      ],
      actionsOverflowButtonSpacing: 5.0,
    );
  }
}
