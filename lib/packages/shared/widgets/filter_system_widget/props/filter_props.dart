import 'applied_filter_model.dart';
import 'filter_list_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';

/*
This class represents the properties regarding how filters should look.
It contains details like close icon, filter data, theme data, and event functions
*/

class FilterProps {
  FilterProps({
    required this.filters,
    this.closeIcon,
    this.onCloseTap,
    this.showCloseIcon,
    this.onFilterChange,
    this.title,
    this.themeProps,
  });
  final List<FilterListModel> filters;
  final String? title;
  final ThemeProps? themeProps;
  final Icon? closeIcon;
  final bool? showCloseIcon;
  final Function? onCloseTap;

  final Function(List<AppliedFilterModel> appliedFilterModel)? onFilterChange;
}

class ThemeProps {
  ThemeProps({
    this.searchBarViewProps,
    this.titleStyle,
    this.titleColor,
    this.inActiveFilterItemBackgroundColor,
    this.resetButtonColor,
    this.submitButtonColor,
    this.divider,
    this.dividerColor,
    this.inActiveFilterHeaderColor,
    this.activeFilterHeaderColor,
    this.activeFilterTextStyle,
    this.activeFilterTextColor,
    this.inActiveFilterTextColor,
    this.inActiveFilterTextStyle,
    this.activeFilterHeaderStyle,
    this.dividerThickness,
    this.resetButtonStyle,
    this.resetButtonThemeStyle,
    this.submitButtonStyle,
    this.submitButtonThemeStyle,
    this.checkBoxTileThemeProps,
    this.radioTileThemeProps,
    this.sliderTileThemeProps,
  });
  final TextStyle? titleStyle;
  final Color? titleColor;
  final Color? activeFilterHeaderColor;
  final Color? inActiveFilterHeaderColor;
  final Color? inActiveFilterItemBackgroundColor;
  final TextStyle? activeFilterHeaderStyle;
  final TextStyle? activeFilterTextStyle;
  final Color? activeFilterTextColor;
  final Color? inActiveFilterTextColor;
  final TextStyle? inActiveFilterTextStyle;
  final Color? resetButtonColor;
  final TextStyle? resetButtonStyle;
  final ButtonStyle? resetButtonThemeStyle;
  final Color? submitButtonColor;
  final TextStyle? submitButtonStyle;
  final ButtonStyle? submitButtonThemeStyle;
  final Widget? divider;
  final Color? dividerColor;
  final double? dividerThickness;
  final SearchBarViewProps? searchBarViewProps;
  final CheckBoxTileThemeProps? checkBoxTileThemeProps;
  final RadioTileThemeProps? radioTileThemeProps;
  final SliderTileThemeProps? sliderTileThemeProps;
}

class CheckBoxTileThemeProps {
  CheckBoxTileThemeProps({
    this.activeCheckBoxColor,
    this.inActiveCheckBoxColor,
    this.checkboxTitleColor,
    this.checkboxTitleStyle,
    this.tileColor,
  });
  final Color? activeCheckBoxColor;
  final Color? inActiveCheckBoxColor;
  final Color? checkboxTitleColor;
  final TextStyle? checkboxTitleStyle;
  final Color? tileColor;
}

class RadioTileThemeProps {
  const RadioTileThemeProps({
    this.activeRadioColor,
    this.inActiveRadioColor,
    this.radioTitleStyle,
    this.radioTitleColor,
    this.tileColor,
  });
  final Color? activeRadioColor;
  final Color? inActiveRadioColor;
  final TextStyle? radioTitleStyle;
  final Color? radioTitleColor;
  final Color? tileColor;
}

class SliderTileThemeProps {
  SliderTileThemeProps({
    this.sliderThemeData,
    this.labelPrefixStr,
    this.labelSuffixStr,
    this.tooltipPrefixStr,
    this.tooltipSuffixStr,
    this.fractionDigits,
    this.stepSize,
  });
  SfRangeSliderThemeData? sliderThemeData;
  String? tooltipPrefixStr;
  String? tooltipSuffixStr;
  String? labelPrefixStr;
  String? labelSuffixStr;
  double? stepSize;
  int? fractionDigits;

  @override
  String toString() {
    return 'SliderTileThemeProps{sliderThemeData: $sliderThemeData, tooltipPrefixStr: $tooltipPrefixStr, tooltipSuffixStr: $tooltipSuffixStr, labelPrefixStr: $labelPrefixStr, labelSuffixStr: $labelSuffixStr, stepSize: $stepSize, fractionDigits: $fractionDigits}';
  }
}

class SearchBarViewProps {
  SearchBarViewProps({
    this.clearIconColor,
    this.searchIconColor,
    this.clearIcon,
    this.searchIcon,
    this.inputBorder,
    this.fillColor,
    this.filled,
    this.searchHint,
    this.hintStyle,
    this.textStyle,
  });
  OutlineInputBorder? inputBorder;
  Color? fillColor;
  Color? clearIconColor;
  Color? searchIconColor;
  Widget? clearIcon;
  Widget? searchIcon;
  bool? filled;
  String? searchHint;
  TextStyle? textStyle;
  TextStyle? hintStyle;
}
