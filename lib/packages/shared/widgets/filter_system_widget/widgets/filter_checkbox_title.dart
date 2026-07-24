/*
This piece of code for that retrun the user interface for CheckboxTileView names as FilterCheckboxTitle.
*/

import '../filter_style_mixin.dart';
import '../props/filter_props.dart';
import 'package:flutter/material.dart';
import 'filter_text.dart';

class FilterCheckboxTitle extends StatelessWidget with FilterStyleMixin {
  const FilterCheckboxTitle({
    required this.selected,
    required this.title,
    required this.onUpdate,
    super.key,
    this.checkBoxTileThemeProps,
  });

  final bool selected;
  final String title;
  final ValueChanged<bool?> onUpdate;
  final CheckBoxTileThemeProps? checkBoxTileThemeProps;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      activeColor: checkBoxTileThemeProps?.activeCheckBoxColor,
      checkColor: checkBoxTileThemeProps?.inActiveCheckBoxColor,
      onChanged: (value) {
        onUpdate(value);
      },
      tileColor: checkBoxTileThemeProps?.tileColor,
      title: FilterText(
        title: title,
        style:
            checkBoxTileThemeProps?.checkboxTitleStyle ??
            getTitleTheme1(context)?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: checkBoxTileThemeProps?.checkboxTitleColor,
            ),
      ),
    );
  }
}
