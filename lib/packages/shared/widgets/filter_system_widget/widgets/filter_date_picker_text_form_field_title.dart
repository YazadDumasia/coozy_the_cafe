import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../props/props.dart';

class FilterDatePickerTextFormFieldTitle extends StatefulWidget {
  const FilterDatePickerTextFormFieldTitle({
    required this.decoration,
    required this.onChanged,
    required this.filterOptions,
    required this.previousApplied,
    super.key,
    this.title,
    this.dateFormat,
    this.value,
  });
  final String? title;
  final InputDecoration? decoration;
  final String? value;
  final String? dateFormat;
  final Function(String)? onChanged;
  final List<FilterItemModel> filterOptions;
  final List<FilterItemModel> previousApplied;

  @override
  FilterDatePickerTextFormFieldTitleState createState() =>
      FilterDatePickerTextFormFieldTitleState();
}

class FilterDatePickerTextFormFieldTitleState
    extends State<FilterDatePickerTextFormFieldTitle> {
  TextEditingController datePickerTextEditingController = TextEditingController(
    text: '',
  );
  FocusNode _focusNode = FocusNode();
  DateTime? date;

  @override
  void initState() {
    super.initState();
    datePickerTextEditingController = TextEditingController(text: '');
    _focusNode = FocusNode();
    datePickerTextEditingController.text = widget.value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          visible: (widget.title == null || widget.title!.isEmpty)
              ? false
              : true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text(widget.title ?? ''),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 15,
                        ),
                        child: TextFormField(
                          onChanged: (value) async {
                            setState(() {
                              widget.onChanged!(value);
                            });
                          },
                          readOnly: true,
                          controller: datePickerTextEditingController,
                          focusNode: _focusNode,
                          decoration: widget.decoration,
                          autovalidateMode: AutovalidateMode.disabled,
                          validator: (value) {
                            return value;
                          },
                          onFieldSubmitted: (String value) {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? datePick;

    if (core.PlatformUtils.isIOS() || core.PlatformUtils.isMacOS()) {
      datePick = await showModalBottomSheet<DateTime?>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          DateTime? tempPickedDate;
          return SizedBox(
            height: 250,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.commonCancel,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Cancel',
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.commonDone,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Done',
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(tempPickedDate);
                      },
                    ),
                  ],
                ),
                const Divider(height: 0, thickness: 1),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    minimumDate: DateTime(DateTime.now().year - 80),
                    initialDateTime: date ?? DateTime.now(),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime dateTime) {
                      tempPickedDate = dateTime;
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      datePick = await showDatePicker(
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 120),
        lastDate: DateTime.now(),
        helpText: 'Date of birth',
      );
    }

    if (datePick != null && datePick != date) {
      date = datePick;
      final String? pick = core.DateUtil.dateToString(datePick, 'dd-MM-yyyy');
      core.PlatformUtils.debugLog(
        FilterDatePickerTextFormFieldTitle,
        'FilterDatePickerTextFormFieldTitle:Date:$pick',
      );
      datePickerTextEditingController.text = pick!;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
