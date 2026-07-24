import 'filter_item_model.dart';
import 'filter_props.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

/// Enumeration for different types of filter options
enum FilterType {
  checkboxList,
  radioGroup,
  slider,
  verticalSlider,
  rangeSlider,
  verticalRangeSlider,
  rangeDateTimePicker,
  rangeDateVerticalTimePicker,
  datePicker,
  timePicker,
  rangeDatePicker,
  rangeTimePicker,
  rangeVerticalTimePicker,
}

/// Filter option model
class FilterListModel extends Equatable {
  const FilterListModel({
    required this.filterKey,
    required this.filterOptions,
    required this.previousApplied,
    required this.type,
    this.title,
    this.inputDateFormat,
    this.labelText,
    this.hintText,
    this.initialDate,
    this.minimumDate,
    this.maximumDate,
    this.datePickerDateOrder,
    this.pickerMode,
    this.sliderTileThemeProps,
    this.backgroundColor,
    this.minuteInterval,
    this.use24hFormat,
    this.textButtonCancel,
    this.textButtonOkay,
    this.helpText,
    this.firstDate,
    this.lastDate,
    this.allowMultipleRecordsInRow = false,
  });
  final String? title;
  final String filterKey;
  final List<FilterItemModel> filterOptions;
  final List<FilterItemModel> previousApplied;
  final FilterType? type;
  final SliderTileThemeProps? sliderTileThemeProps;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? initialDate;
  final String? labelText;
  final String? hintText;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final DatePickerDateOrder? datePickerDateOrder;
  final DateFormat? inputDateFormat;
  final Color? backgroundColor;
  final int? minuteInterval;
  final bool? use24hFormat;
  final String? textButtonCancel;
  final String? textButtonOkay;
  final String? helpText;
  final CupertinoDatePickerMode? pickerMode;
  final bool allowMultipleRecordsInRow;

  FilterListModel copyWith({
    List<FilterItemModel>? filterOptions,
    List<FilterItemModel>? previousApplied,
    String? title,
    String? labelText,
    String? hintText,
    String? filterKey,
    FilterType? type,
    SliderTileThemeProps? sliderTileThemeProps,
    DateFormat? inputDateFormat,
    String? initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    Color? backgroundColor,
    int? minuteInterval,
    bool? use24hFormat,
    String? textButtonCancel,
    String? textButtonOkay,
    String? helpText,
    DatePickerDateOrder? datePickerDateOrder,
    CupertinoDatePickerMode? pickerMode,
    bool? allowMultipleRecordsInRow,
  }) {
    return FilterListModel(
      title: title ?? this.title,
      labelText: labelText ?? this.labelText,
      hintText: hintText ?? this.hintText,
      type: type ?? this.type,
      filterKey: filterKey ?? this.filterKey,
      filterOptions: filterOptions ?? this.filterOptions,
      previousApplied: previousApplied ?? this.previousApplied,
      sliderTileThemeProps: sliderTileThemeProps ?? this.sliderTileThemeProps,
      inputDateFormat: inputDateFormat ?? this.inputDateFormat,
      initialDate: initialDate ?? this.initialDate,
      minimumDate: minimumDate ?? this.minimumDate,
      maximumDate: maximumDate ?? this.maximumDate,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      minuteInterval: minuteInterval ?? this.minuteInterval,
      use24hFormat: use24hFormat ?? this.use24hFormat,
      textButtonCancel: textButtonCancel ?? this.textButtonCancel,
      textButtonOkay: textButtonOkay ?? this.textButtonOkay,
      helpText: helpText ?? this.helpText,
      pickerMode: pickerMode ?? this.pickerMode,
      datePickerDateOrder: datePickerDateOrder ?? this.datePickerDateOrder,
      allowMultipleRecordsInRow:
          allowMultipleRecordsInRow ?? this.allowMultipleRecordsInRow,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    title,
    filterKey,
    type,
    filterOptions,
    previousApplied,
    sliderTileThemeProps,
    firstDate,
    lastDate,
    inputDateFormat,
    datePickerDateOrder,
    pickerMode,
    initialDate,
    minimumDate,
    maximumDate,
    hintText,
    labelText,
    backgroundColor,
    minuteInterval,
    use24hFormat,
    helpText,
    textButtonCancel,
    textButtonOkay,
    allowMultipleRecordsInRow,
  ];

  Map<String, dynamic> toMap() {
    return (<String, dynamic>{
      'title': title,
      'filter_key': filterKey,
      'type': type.toString().split('.').last,
      'previous_applied': previousApplied.map((e) => e.toMap()).toList(),
      'filter_options': filterOptions.map((e) => e.toMap()).toList(),
      'SliderTileThemeProps': sliderTileThemeProps.toString(),
      'inputDateFormat': inputDateFormat.toString(),
      'initialDate': initialDate.toString(),
      'minimumDate': minimumDate.toString(),
      'maximumDate': maximumDate.toString(),
      'labelText': labelText,
      'hintText': hintText,
      'backgroundColor': backgroundColor,
      'minuteInterval': minuteInterval,
      'use24hFormat': use24hFormat,
      'textButtonCancel': textButtonCancel,
      'helpText': helpText,
      'textButtonOkay': textButtonOkay,
      'allowMultipleRecordsInRow': allowMultipleRecordsInRow,
    });
  }
}
