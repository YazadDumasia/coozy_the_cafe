/*
This piece of code for that retrun the user interface for CheckboxTileView names as FilterCheckboxTitle.
*/

import '../filter_style_mixin.dart';
import '../props/filter_item_model.dart';
import '../props/filter_props.dart';
import 'package:flutter/material.dart';
import 'filter_text.dart';

class FilterRadioBoxTitle extends StatelessWidget with FilterStyleMixin {
  const FilterRadioBoxTitle({
    required this.options,
    super.key,
    this.selectedOption,
    this.onChanged,
    this.radioTileThemeProps,
  });
  final List<FilterItemModel> options;
  final FilterItemModel? selectedOption;
  final void Function(FilterItemModel?)? onChanged;

  final RadioTileThemeProps? radioTileThemeProps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((FilterItemModel option) {
        // return ListTile(
        //   title: Text(option.filterTitle ?? ''),
        //   leading: Radio<FilterItemModel>(
        //     value: option,
        //     groupValue: selectedOption,
        //     onChanged: onChanged,
        //   ),
        // );
        return RadioListTile<FilterItemModel>(
          title: FilterText(
            title: option.filterTitle,
            style:
                radioTileThemeProps?.radioTitleStyle ??
                getTitleTheme1(context)?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: radioTileThemeProps?.radioTitleColor,
                ),
          ),
          value: option,
          // ignore: deprecated_member_use
          groupValue: selectedOption,
          // ignore: deprecated_member_use
          onChanged: onChanged,
          tileColor: radioTileThemeProps?.tileColor,
          activeColor: radioTileThemeProps?.activeRadioColor,
          materialTapTargetSize: MaterialTapTargetSize.padded,
        );
      }).toList(),
    );
  }
}
