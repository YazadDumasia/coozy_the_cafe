/// Main widget for filtering data
/// Required parametter is FilterProps
library;

import 'package:coozy_the_cafe/packages/shared/config/app_extensions.dart';
import 'package:coozy_the_cafe/packages/shared/l10n/locale_keys.dart';
import 'package:coozy_the_cafe/packages/shared/l10n/track_constants.dart';

import '../../../../core/coozy_core.dart' as core;
import '../filter_style_mixin.dart';
import '../props/filter_item_model.dart';
import '../props/filter_list_model.dart';
import '../props/filter_props.dart';
import '../state/filter_cubit.dart';
import 'datetime_picker_formfield.dart';
import 'filter_checkbox_title.dart';
import 'filter_radio_box_title.dart';
import 'filter_range_slider_title.dart';
import 'filter_range_slider_vertical_title.dart';
import 'filter_slider_title.dart';
import 'filter_slider_vertical_title.dart';
import 'show_date_picker_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'filter_text.dart';
import 'filter_text_button.dart';

class FilterWidget extends StatelessWidget {
  const FilterWidget({required this.filterProps, super.key});

  final FilterProps filterProps;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FilterCubit(filterProps: filterProps),
      child: const Filter(),
    );
  }
}

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> with FilterStyleMixin {
  late FilterCubit _filterCubit;

  final ValueNotifier<String> _searchValueNotifier = ValueNotifier<String>('');
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _filterCubit = context.read<FilterCubit>();
    super.initState();
  }

  void _clearSearch() {
    _searchValueNotifier.value = '';
    _searchController.clear();
    _filterCubit.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FilterCubit, FilterState>(
      listener: (context, state) {},
      builder: (_, state) {
        final ThemeProps? themeProps = _filterCubit.filterProps.themeProps;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FilterText(
                    title: _filterCubit.filterProps.title ?? 'Filters',
                    style: themeProps?.titleStyle,
                    fontColor: themeProps?.titleColor,
                  ),
                  Visibility(
                    visible: (_filterCubit.filterProps.showCloseIcon ?? true),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      onPressed: () {
                        if (_filterCubit.filterProps.onCloseTap != null) {
                          _filterCubit.filterProps.onCloseTap!();
                        }
                        Navigator.of(context).pop();
                      },
                      icon:
                          _filterCubit.filterProps.closeIcon ??
                          const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
            themeProps?.divider ??
                Container(
                  height: themeProps?.dividerThickness ?? 2,
                  width: MediaQuery.of(context).size.width,
                  color: themeProps?.dividerColor ?? getDividerColor(context),
                ),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      flex: 4,
                      child: Scrollbar(
                        interactive: true,
                        child: CustomScrollView(
                          physics: const ClampingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          shrinkWrap: true,
                          slivers: <Widget>[
                            SliverPadding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 5,
                                top: 5,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final FilterListModel filterTitleListModel =
                                        state.filters![index];
                                    return Material(
                                      type: MaterialType.transparency,
                                      child: InkWell(
                                        splashColor: Theme.of(
                                          context,
                                        ).splashColor,
                                        onTap: () {
                                          _clearSearch();
                                          _filterCubit.onFilterTitleTap(index);
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                color:
                                                    (index ==
                                                        state.activeFilterIndex)
                                                    ? themeProps
                                                              ?.inActiveFilterItemBackgroundColor ??
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primaryContainer
                                                    : null,
                                                padding: const EdgeInsets.only(
                                                  left: 10,
                                                  top: 5,
                                                  bottom: 5,
                                                ),
                                                child: FilterText(
                                                  title:
                                                      filterTitleListModel
                                                          .title ??
                                                      '',
                                                  fontSize: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .fontSize,
                                                  style:
                                                      (index ==
                                                          state
                                                              .activeFilterIndex)
                                                      // ? themeProps
                                                      //     ?.activeFilterTextStyle
                                                      ? themeProps
                                                            ?.inActiveFilterTextStyle
                                                      : themeProps
                                                            ?.inActiveFilterTextStyle,
                                                  fontWeight: FontWeight.w500,
                                                  fontColor:
                                                      (index ==
                                                          state
                                                              .activeFilterIndex)
                                                      ? themeProps
                                                                ?.activeFilterTextColor ??
                                                            getTheme(
                                                              context,
                                                            ).primaryColor
                                                      : themeProps
                                                            ?.inActiveFilterTextColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  addSemanticIndexes: true,
                                  addAutomaticKeepAlives: true,
                                  addRepaintBoundaries: false,
                                  childCount: state.filters?.length ?? 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    themeProps?.divider ??
                        Container(
                          height: double.maxFinite,
                          width: themeProps?.dividerThickness ?? 1,
                          color:
                              themeProps?.dividerColor ??
                              getDividerColor(context),
                        ),
                    Flexible(
                      flex: 6,
                      child: customFilterWidget(state, themeProps),
                    ),
                  ],
                ),
              ),
            ),
            themeProps?.divider ??
                Container(
                  height: themeProps?.dividerThickness ?? 2,
                  width: MediaQuery.of(context).size.width,
                  color: themeProps?.dividerColor ?? getDividerColor(context),
                ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              // color: getTheme(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    FilterTextButton(
                      text:
                          context.tr(
                            LocaleKeys.commonReset,
                            track: TrackConstants.commonTrack,
                          ) ??
                          'Reset',
                      isSecondary: true,
                      onTap: () {
                        _filterCubit.onFilterRemove();
                        Navigator.of(context).pop();
                      },
                      style: themeProps?.resetButtonStyle,
                      buttonStyle: themeProps?.resetButtonThemeStyle,
                      txtColor: themeProps?.resetButtonColor,
                    ),
                    FilterTextButton(
                      text:
                          context.tr(
                            LocaleKeys.commonApply,
                            track: TrackConstants.commonTrack,
                          ) ??
                          'Apply',
                      isElevatedButton: true,
                      txtColor:
                          themeProps?.submitButtonColor ??
                          getTheme(context).colorScheme.secondary,
                      onTap: () {
                        _filterCubit.onFilterSubmit();
                        Navigator.of(context).pop();
                      },
                      style: themeProps?.submitButtonStyle,
                      buttonStyle: themeProps?.submitButtonThemeStyle,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  dynamic customFilterWidget(FilterState state, ThemeProps? themeProps) {
    if (state.filters!.isEmpty) {
      return const SizedBox.shrink();
    } else {
      switch (state.type) {
        case FilterType.checkboxList:
          return checkboxWidget(state, themeProps);
        case FilterType.radioGroup:
          return radioGroupWidget(state, themeProps);
        case FilterType.slider:
          return sliderWidget(state, themeProps);
        case FilterType.verticalSlider:
          return verticalSliderWidget(state, themeProps);
        case FilterType.rangeSlider:
          return rangerSliderTitleWidget(state, themeProps);
        case FilterType.verticalRangeSlider:
          return rangerVerticalSliderTitleWidget(state, themeProps);
        case FilterType.datePicker:
          return datePickerWidget(state, themeProps);
        case FilterType.timePicker:
          return timePickerWidget(state, themeProps);
        case FilterType.rangeDatePicker:
          return rangeDatePickerWidget(state, themeProps);
        case FilterType.rangeTimePicker:
          return rangeTimePickerWidget(state, themeProps);
        default:
          return Container();
      }
    }
  }

  double findSliderValue(List<FilterItemModel>? filterOptions) {
    // Use reduce to find the minimum value
    try {
      return filterOptions
              ?.map<double?>((item) {
                return double.tryParse('${item.filterKey}') ?? 0.0;
              })
              .whereType<double>()
              .reduce(
                (minValue, value) => value < minValue ? value : minValue,
              ) ??
          0.0;
    } catch (e) {
      core.PlatformUtils.debugLog(FilterWidget, e.toString());
      return 0.0;
    }
  }

  double? findMinValue(List<FilterItemModel>? filterOptions) {
    // Use reduce to find the minimum value
    try {
      return filterOptions
              ?.map<double?>((item) {
                return double.tryParse('${item.filterKey}') ?? 0.0;
              })
              .whereType<double>()
              .reduce(
                (minValue, value) => value < minValue ? value : minValue,
              ) ??
          0.0;
    } catch (e) {
      return 0.0;
    }
  }

  double? findMaxValue(List<FilterItemModel>? filterOptions) {
    // Use reduce to find the maximum value
    try {
      return filterOptions
              ?.map<double?>((item) {
                return double.tryParse('${item.filterKey}') ?? 0.0;
              })
              .whereType<double>()
              .reduce(
                (maxValue, value) => value > maxValue ? value : maxValue,
              ) ??
          0.0;
    } catch (e) {
      core.PlatformUtils.debugLog(FilterWidget, e.toString());
      return 0.0;
    }
  }

  SizedBox checkboxWidget(FilterState state, ThemeProps? themeProps) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Builder(
        builder: (context) {
          final List<FilterItemModel> list =
              state.filters![state.activeFilterIndex].filterOptions;

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 7,
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: _searchValueNotifier,
                  builder: (context, searchValue, child) {
                    return TextFormField(
                      controller: _searchController,
                      style: themeProps?.searchBarViewProps?.textStyle,
                      decoration: InputDecoration(
                        hintText:
                            themeProps?.searchBarViewProps?.searchHint ??
                            'Search',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        hintStyle: themeProps?.searchBarViewProps?.hintStyle,
                        fillColor:
                            themeProps?.searchBarViewProps?.fillColor
                                ?.withValues(alpha: 0.8) ??
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                        filled: themeProps?.searchBarViewProps?.filled ?? true,
                        border:
                            themeProps?.searchBarViewProps?.inputBorder ??
                            OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                width: 1,
                                color:
                                    themeProps?.searchBarViewProps?.fillColor ??
                                    getTheme(context).primaryColor,
                              ),
                            ),
                        suffixIcon: searchValue.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _clearSearch();
                                },
                                icon:
                                    themeProps?.searchBarViewProps?.clearIcon ??
                                    Icon(
                                      Icons.close,
                                      color: themeProps
                                          ?.searchBarViewProps
                                          ?.clearIconColor,
                                    ),
                              )
                            : IconButton(
                                onPressed: () {
                                  _filterCubit.filterBySearch(
                                    _searchController.text,
                                  );
                                },
                                icon:
                                    themeProps
                                        ?.searchBarViewProps
                                        ?.searchIcon ??
                                    Icon(
                                      Icons.search,
                                      color: themeProps
                                          ?.searchBarViewProps
                                          ?.searchIconColor,
                                    ),
                              ),
                      ),
                      onFieldSubmitted: (value) {},
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        _searchValueNotifier.value = value;
                        if (value.isEmpty) {
                          _clearSearch();
                        } else {
                          _filterCubit.filterBySearch(_searchController.text);
                        }
                      },
                    );
                  },
                ),
              ),
              Visibility(
                visible: list.isNotEmpty,
                child: Expanded(
                  child: Scrollbar(
                    interactive: true,
                    trackVisibility: true,
                    child: CustomScrollView(
                      physics: const ClampingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      shrinkWrap: true,
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          sliver:
                              state
                                  .filters![state.activeFilterIndex]
                                  .allowMultipleRecordsInRow
                              ? SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisExtent: 56,
                                      ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final FilterItemModel item = list[index];
                                      return FilterCheckboxTitle(
                                        checkBoxTileThemeProps:
                                            themeProps?.checkBoxTileThemeProps,
                                        selected: _filterCubit.checked(
                                          state
                                              .filters![state.activeFilterIndex]
                                              .previousApplied,
                                          item,
                                        ),
                                        title: item.filterTitle,
                                        onUpdate: (bool? value) {
                                          _filterCubit.onFilterItemCheck(item);
                                        },
                                      );
                                    },
                                    addSemanticIndexes: true,
                                    addAutomaticKeepAlives: false,
                                    addRepaintBoundaries: true,
                                    childCount: list.length,
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final FilterItemModel item = list[index];
                                      return FilterCheckboxTitle(
                                        checkBoxTileThemeProps:
                                            themeProps?.checkBoxTileThemeProps,
                                        selected: _filterCubit.checked(
                                          state
                                              .filters![state.activeFilterIndex]
                                              .previousApplied,
                                          item,
                                        ),
                                        title: item.filterTitle,
                                        onUpdate: (bool? value) {
                                          _filterCubit.onFilterItemCheck(item);
                                        },
                                      );
                                    },
                                    addSemanticIndexes: true,
                                    addAutomaticKeepAlives: false,
                                    addRepaintBoundaries: true,
                                    childCount: list.length,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SizedBox radioGroupWidget(FilterState state, ThemeProps? themeProps) {
    final List<FilterItemModel> list =
        state.filters![state.activeFilterIndex].filterOptions;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 7,
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: _searchValueNotifier,
                  builder: (context, searchValue, child) {
                    return TextFormField(
                      controller: _searchController,
                      style: themeProps?.searchBarViewProps?.textStyle,
                      decoration: InputDecoration(
                        hintText:
                            themeProps?.searchBarViewProps?.searchHint ??
                            'Search',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        hintStyle: themeProps?.searchBarViewProps?.hintStyle,
                        fillColor:
                            themeProps?.searchBarViewProps?.fillColor
                                ?.withValues(alpha: 0.8) ??
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                        filled: themeProps?.searchBarViewProps?.filled ?? true,
                        border:
                            themeProps?.searchBarViewProps?.inputBorder ??
                            OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                width: 1,
                                color:
                                    themeProps?.searchBarViewProps?.fillColor ??
                                    getTheme(context).primaryColor,
                              ),
                            ),
                        suffixIcon: searchValue.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _clearSearch();
                                },
                                icon:
                                    themeProps?.searchBarViewProps?.clearIcon ??
                                    Icon(
                                      Icons.close,
                                      color: themeProps
                                          ?.searchBarViewProps
                                          ?.clearIconColor,
                                    ),
                              )
                            : IconButton(
                                onPressed: () {
                                  _filterCubit.filterBySearch(
                                    _searchController.text,
                                  );
                                },
                                icon:
                                    themeProps
                                        ?.searchBarViewProps
                                        ?.searchIcon ??
                                    Icon(
                                      Icons.search,
                                      color: themeProps
                                          ?.searchBarViewProps
                                          ?.searchIconColor,
                                    ),
                              ),
                      ),
                      onFieldSubmitted: (value) {},
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        _searchValueNotifier.value = value;
                        if (value.isEmpty) {
                          _clearSearch();
                        } else {
                          _filterCubit.filterBySearch(_searchController.text);
                        }
                      },
                    );
                  },
                ),
              ),
              Visibility(
                visible: list.isNotEmpty,
                child: Expanded(
                  child: Scrollbar(
                    interactive: true,
                    trackVisibility: true,
                    child: CustomScrollView(
                      physics: const ClampingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      shrinkWrap: true,
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          sliver:
                              state
                                  .filters![state.activeFilterIndex]
                                  .allowMultipleRecordsInRow
                              ? SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisExtent: 56,
                                      ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final FilterItemModel item = list[index];
                                      return FilterRadioBoxTitle(
                                        options: <FilterItemModel>[item],
                                        selectedOption:
                                            _filterCubit.checked(
                                              state
                                                  .filters![state
                                                      .activeFilterIndex]
                                                  .previousApplied,
                                              item,
                                            )
                                            ? item
                                            : null,
                                        onChanged: (selected) {
                                          _filterCubit.onFilterItemCheck(item);
                                        },
                                        radioTileThemeProps:
                                            themeProps?.radioTileThemeProps,
                                      );
                                    },
                                    addSemanticIndexes: true,
                                    addAutomaticKeepAlives: true,
                                    addRepaintBoundaries: false,
                                    childCount: list.length,
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final FilterItemModel item = list[index];
                                      return FilterRadioBoxTitle(
                                        options: <FilterItemModel>[item],
                                        selectedOption:
                                            _filterCubit.checked(
                                              state
                                                  .filters![state
                                                      .activeFilterIndex]
                                                  .previousApplied,
                                              item,
                                            )
                                            ? item
                                            : null,
                                        onChanged: (selected) {
                                          _filterCubit.onFilterItemCheck(item);
                                        },
                                        radioTileThemeProps:
                                            themeProps?.radioTileThemeProps,
                                      );
                                    },
                                    addSemanticIndexes: true,
                                    addAutomaticKeepAlives: true,
                                    addRepaintBoundaries: false,
                                    childCount: list.length,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Row sliderWidget(FilterState state, ThemeProps? themeProps) {
    final List<FilterItemModel> filterOptions =
        state.filters![state.activeFilterIndex].filterOptions;
    final List<FilterItemModel> previousApplied =
        state.filters![state.activeFilterIndex].previousApplied;
    final String title = state.filters![state.activeFilterIndex].title ?? '';

    final double? minValue = findMinValue(filterOptions);
    final double? maxValue = findMaxValue(filterOptions);

    final double values = (previousApplied.isEmpty)
        ? 0.0
        : double.tryParse('${previousApplied.first.filterKey ?? 0.0}') ?? 0.0;
    final SliderTileThemeProps? sliderTileThemeProps =
        state.filters![state.activeFilterIndex].sliderTileThemeProps;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: FilterSliderTitle(
            sliderTileThemeProps: sliderTileThemeProps,
            filterOptions: filterOptions,
            previousApplied: previousApplied,
            title: title,
            values: values,
            minValue: minValue!,
            maxValue: maxValue!,
            onChanged: (newValues) {
              final FilterItemModel model = FilterItemModel(
                filterKey: newValues,
                filterTitle: '$newValues',
              );
              context.read<FilterCubit>().onFilterItemCheck(model);
            },
          ),
        ),
      ],
    );
  }

  Row verticalSliderWidget(FilterState state, ThemeProps? themeProps) {
    final List<FilterItemModel> filterOptions =
        state.filters![state.activeFilterIndex].filterOptions;
    final List<FilterItemModel> previousApplied =
        state.filters![state.activeFilterIndex].previousApplied;
    final String title = state.filters![state.activeFilterIndex].title ?? '';

    final double? minValue = findMinValue(filterOptions);
    final double? maxValue = findMaxValue(filterOptions);

    final double values = (previousApplied.isEmpty)
        ? 0.0
        : double.tryParse('${previousApplied.first.filterKey}') ?? 0.0;
    final SliderTileThemeProps? sliderTileThemeProps =
        state.filters![state.activeFilterIndex].sliderTileThemeProps;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: FilterVerticalSliderTitle(
            sliderTileThemeProps: sliderTileThemeProps,
            filterOptions: filterOptions,
            previousApplied: previousApplied,
            title: title,
            values: values,
            minValue: minValue!,
            maxValue: maxValue!,
            onChanged: (double newValues) async {
              final FilterItemModel model = FilterItemModel(
                filterKey: newValues,
                filterTitle: '$newValues',
              );
              context.read<FilterCubit>().onFilterItemCheck(model);
            },
          ),
        ),
      ],
    );
  }

  Row rangerSliderTitleWidget(FilterState state, ThemeProps? themeProps) {
    final List<FilterItemModel> filterOptions =
        state.filters![state.activeFilterIndex].filterOptions;
    final List<FilterItemModel> previousApplied =
        state.filters![state.activeFilterIndex].previousApplied;
    final String title = state.filters![state.activeFilterIndex].title ?? '';
    core.PlatformUtils.debugLog(
      FilterWidget,
      'rangerSliderTitleWidget:rangerSliderTitleWidget',
    );

    final double? minValue = findMinValue(filterOptions);
    final double? maxValue = findMaxValue(filterOptions);

    double? minPreviousAppliedValue;
    double? maxPreviousAppliedValue;
    if (previousApplied.isEmpty) {
      minPreviousAppliedValue = 0.0;
      maxPreviousAppliedValue = 0.0;
    } else {
      minPreviousAppliedValue = findMinValue(previousApplied);
      maxPreviousAppliedValue = findMaxValue(previousApplied);
    }
    final SfRangeValues values = ((previousApplied.isEmpty)
        ? SfRangeValues(minValue ?? 0.0, maxValue ?? 0.0)
        : SfRangeValues(
            minPreviousAppliedValue ?? 0.0,
            maxPreviousAppliedValue ?? 0.0,
          ));
    final SliderTileThemeProps? sliderTileThemeProps =
        state.filters![state.activeFilterIndex].sliderTileThemeProps;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: FilterRangerSliderTitle(
            sliderTileThemeProps: sliderTileThemeProps,
            filterOptions: filterOptions,
            previousApplied: previousApplied,
            title: title,
            values: values,
            minValue: minValue!,
            maxValue: maxValue!,
            onChanged: (newValues) async {
              final FilterItemModel startModel = FilterItemModel(
                filterKey: newValues.start,
                filterTitle: '${newValues.start}',
              );
              final FilterItemModel endModel = FilterItemModel(
                filterKey: newValues.end,
                filterTitle: '${newValues.end}',
              );
              final List<FilterItemModel> list = <FilterItemModel>[];
              list.add(startModel);
              list.add(endModel);
              core.PlatformUtils.debugLog(
                FilterWidget,
                'rangerSliderTitleWidget:rangerSliderTitleWidget:onChanged:${list.toString()}',
              );
              context.read<FilterCubit>().onFilterItemCheck(list);
            },
          ),
        ),
      ],
    );
  }

  Row rangerVerticalSliderTitleWidget(
    FilterState state,
    ThemeProps? themeProps,
  ) {
    final List<FilterItemModel> filterOptions =
        state.filters![state.activeFilterIndex].filterOptions;
    final List<FilterItemModel> previousApplied =
        state.filters![state.activeFilterIndex].previousApplied;
    final String title = state.filters![state.activeFilterIndex].title ?? '';
    core.PlatformUtils.debugLog(
      FilterWidget,
      'rangerSliderTitleWidget:rangerSliderTitleWidget',
    );

    final double? minValue = findMinValue(filterOptions);
    final double? maxValue = findMaxValue(filterOptions);

    double? minPreviousAppliedValue;
    double? maxPreviousAppliedValue;
    if (previousApplied.isEmpty) {
      minPreviousAppliedValue = 0.0;
      maxPreviousAppliedValue = 0.0;
    } else {
      minPreviousAppliedValue = findMinValue(previousApplied);
      maxPreviousAppliedValue = findMaxValue(previousApplied);
    }
    final SfRangeValues values = ((previousApplied.isEmpty)
        ? SfRangeValues(minValue ?? 0.0, maxValue ?? 0.0)
        : SfRangeValues(
            minPreviousAppliedValue ?? 0.0,
            maxPreviousAppliedValue ?? 0.0,
          ));
    final SliderTileThemeProps? sliderTileThemeProps =
        state.filters![state.activeFilterIndex].sliderTileThemeProps;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: FilterVerticalRangerSliderTitle(
            sliderTileThemeProps: sliderTileThemeProps,
            filterOptions: filterOptions,
            previousApplied: previousApplied,
            title: title,
            values: values,
            minValue: minValue!,
            maxValue: maxValue!,
            onChanged: (newValues) async {
              final FilterItemModel startModel = FilterItemModel(
                filterKey: newValues.start,
                filterTitle: '${newValues.start}',
              );
              final FilterItemModel endModel = FilterItemModel(
                filterKey: newValues.end,
                filterTitle: '${newValues.end}',
              );
              final List<FilterItemModel> list = <FilterItemModel>[];
              list.add(startModel);
              list.add(endModel);
              core.PlatformUtils.debugLog(
                FilterWidget,
                'rangerSliderTitleWidget:rangerSliderTitleWidget:onChanged:${list.toString()}',
              );
              context.read<FilterCubit>().onFilterItemCheck(list);
            },
          ),
        ),
      ],
    );
  }

  StatefulBuilder datePickerWidget(FilterState state, ThemeProps? themeProps) {
    final List<FilterItemModel> previousApplied =
        state.filters![state.activeFilterIndex].previousApplied;

    final DateFormat inputDateFormat =
        state.filters![state.activeFilterIndex].inputDateFormat ??
        DateFormat(core.DateUtil.dateFormat9);
    final String title = state.filters![state.activeFilterIndex].title ?? '';
    final String labelText =
        state.filters![state.activeFilterIndex].labelText ?? '';
    final String hintText =
        state.filters![state.activeFilterIndex].hintText ?? '';

    final String textButtonOkay =
        state.filters![state.activeFilterIndex].textButtonOkay ?? 'Okay';
    final String textButtonCancel =
        state.filters![state.activeFilterIndex].textButtonCancel ?? 'Cancel';

    final DateTime minimumDate =
        state.filters![state.activeFilterIndex].minimumDate ??
        DateTime(DateTime.now().year - 150, 1, 1);
    final DateTime maximumDate =
        state.filters![state.activeFilterIndex].maximumDate ??
        DateTime(DateTime.now().year + 150, 1, 1);

    final CupertinoDatePickerMode pickerMode =
        state.filters![state.activeFilterIndex].pickerMode ??
        CupertinoDatePickerMode.date;

    final Color backgroundColor =
        state.filters![state.activeFilterIndex].backgroundColor ??
        Theme.of(context).colorScheme.surface;

    // final currentValue = filterOptions!.first.filterKey.toString();
    final DatePickerDateOrder datePickerDateOrder =
        state.filters![state.activeFilterIndex].datePickerDateOrder ??
        DatePickerDateOrder.dmy;

    DateTime? previousDate;

    if (previousApplied.isEmpty) {
      previousDate = inputDateFormat.tryParse(
        state.filters![state.activeFilterIndex].initialDate ??
            DateTime.now().toIso8601String(),
      );
    } else {
      previousDate = previousDate = inputDateFormat.tryParse(
        DateTime.now().toIso8601String(),
      );
    }
    final TextEditingController textEditingController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 10,
                bottom: 0.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Expanded(child: Text(title))],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: DateTimeField(
                      format: inputDateFormat,
                      autofocus: false,
                      onShowPicker: (context, currentValue) async {
                        final DateTime? selectedDate =
                            await showDatePickerSheet(
                              context: context,
                              dateFormat: inputDateFormat,
                              initialDate: previousDate ?? DateTime.now(),
                              pickerMode: pickerMode,
                              dateOrder: datePickerDateOrder,
                              backgroundColor: backgroundColor,
                              minimumDate: minimumDate,
                              maximumDate: maximumDate,
                              textButtonOkay: textButtonOkay,
                              textButtonCancel: textButtonCancel,
                            );

                        if (!context.mounted) return currentValue;

                        if (selectedDate == null) {
                          core.PlatformUtils.debugLog(
                            FilterWidget,
                            'datePickerWidget:Date selection canceled',
                          );
                          context.read<FilterCubit>().onFilterItemCheck(null);
                        } else {
                          core.PlatformUtils.debugLog(
                            FilterWidget,
                            'datePickerWidget:Selected Date: ${selectedDate.toIso8601String()}',
                          );
                          final FilterItemModel model = FilterItemModel(
                            filterKey:
                                inputDateFormat
                                    .tryParse(selectedDate.toIso8601String())
                                    ?.toIso8601String() ??
                                '',
                            filterTitle:
                                inputDateFormat
                                    .tryParse(selectedDate.toIso8601String())
                                    ?.toIso8601String() ??
                                '',
                          );
                          context.read<FilterCubit>().onFilterItemCheck(model);
                        }
                        return selectedDate;
                      },
                      onChanged: (DateTime? value) {
                        core.PlatformUtils.debugLog(
                          FilterWidget,
                          'datePickerWidget:${value?.toIso8601String()}',
                        );
                        if (value == null) {
                          context.read<FilterCubit>().onFilterItemCheck(null);
                        } else {
                          final FilterItemModel model = FilterItemModel(
                            filterKey:
                                inputDateFormat
                                    .tryParse(value.toIso8601String())
                                    ?.toIso8601String() ??
                                '',
                            filterTitle:
                                inputDateFormat
                                    .tryParse(value.toIso8601String())
                                    ?.toIso8601String() ??
                                '',
                          );
                          context.read<FilterCubit>().onFilterItemCheck(model);
                        }
                      },
                      initialValue: previousDate,
                      autovalidateMode: AutovalidateMode.disabled,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        labelText: labelText,
                        hintText: hintText,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).disabledColor,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder timePickerWidget(FilterState state, ThemeProps? themeProps) {
    final List<FilterItemModel> previousApplied =
        state.filters![state.activeFilterIndex].previousApplied;
    final String title = state.filters![state.activeFilterIndex].title ?? '';

    final DateFormat inputDateFormat =
        state.filters![state.activeFilterIndex].inputDateFormat ??
        DateFormat('hh:mm:ss aaa');

    final String labelText =
        state.filters![state.activeFilterIndex].labelText ?? '';
    final String hintText =
        state.filters![state.activeFilterIndex].hintText ?? '';

    final Color? backgroundColor =
        state.filters![state.activeFilterIndex].backgroundColor;
    final int? minuteInterval =
        state.filters![state.activeFilterIndex].minuteInterval;
    final bool? use24hFormat =
        state.filters![state.activeFilterIndex].use24hFormat;
    final String? textButtonCancel =
        state.filters![state.activeFilterIndex].textButtonCancel;
    final String? textButtonOkay =
        state.filters![state.activeFilterIndex].textButtonOkay;

    DateTime? initialDate;
    TimeOfDay? initialTime;

    if (previousApplied.isEmpty) {
      initialDate =
          (state.filters![state.activeFilterIndex].initialDate == null ||
              state.filters![state.activeFilterIndex].initialDate!.isEmpty)
          ? DateTime.now()
          : core.DateUtil.stringToDate(
              state.filters![state.activeFilterIndex].initialDate!,
              inputDateFormat.pattern!,
            );
      initialTime = core.DateUtil.dateTimeToTimeOfDay(initialDate);
    } else {
      initialDate = core.DateUtil.stringToDate(
        previousApplied.first.filterKey!,
        inputDateFormat.pattern!,
      );
      initialTime = core.DateUtil.dateTimeToTimeOfDay(initialDate);
    }

    core.PlatformUtils.debugLog(FilterWidget, 'timePickerWidget');
    final TextEditingController textEditingController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 10,
                bottom: 0.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Expanded(child: Text(title))],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: DateTimeField(
                      format: inputDateFormat,
                      autofocus: false,
                      onShowPicker: (context, currentValue) async {
                        final TimeOfDay? time = await showTimePickerSheet(
                          context: context,
                          initialTime: initialTime,
                          backgroundColor:
                              backgroundColor ??
                              Theme.of(context).colorScheme.surface,
                          minuteInterval: minuteInterval ?? 1,
                          use24hFormat: use24hFormat!,
                          textButtonOkay: textButtonOkay,
                          textButtonCancel: textButtonCancel,
                        );
                        return DateTimeField.convert(time);
                      },
                      onChanged: (value) {
                        core.PlatformUtils.debugLog(
                          FilterWidget,
                          'timePickerWidget:${value.toString()}',
                        );
                      },
                      initialValue: initialDate,
                      autovalidateMode: AutovalidateMode.disabled,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        labelText: labelText,
                        hintText: hintText,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).disabledColor,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).unfocus();
                      },
                      validator: (value) {
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder rangeDatePickerWidget(
    FilterState state,
    ThemeProps? themeProps,
  ) {
    final List<FilterItemModel> previousApplied =
        state.filters![state.activeFilterIndex].previousApplied;

    final String title = state.filters![state.activeFilterIndex].title ?? '';

    final DateFormat inputDateFormat =
        state.filters![state.activeFilterIndex].inputDateFormat ??
        DateFormat('dd-MM-yyyy');

    final DateTime minimumDate =
        state.filters![state.activeFilterIndex].minimumDate ??
        DateTime(DateTime.now().year - 150, 1, 1);
    final DateTime maximumDate =
        state.filters![state.activeFilterIndex].maximumDate ??
        DateTime(DateTime.now().year + 150, 1, 1);

    final String labelText =
        state.filters![state.activeFilterIndex].labelText ?? '';
    final String hintText =
        state.filters![state.activeFilterIndex].hintText ?? '';
    final String helpText =
        state.filters![state.activeFilterIndex].helpText ?? '';
    final String? textButtonCancel =
        state.filters![state.activeFilterIndex].textButtonCancel;
    final String? textButtonOkay =
        state.filters![state.activeFilterIndex].textButtonOkay;

    DateTimeRange? initialDateRange;
    if (previousApplied.isEmpty) {
      final String? initialDate =
          state.filters![state.activeFilterIndex].initialDate;

      if (initialDate == null || initialDate.isEmpty) {
        final DateTime now = DateTime.now();
        initialDateRange = DateTimeRange(
          start: now,
          end: now.add(const Duration(days: 1)),
        );
      } else {
        final DateTime startDate = core.DateUtil.stringToDate(
          initialDate,
          inputDateFormat.pattern!,
        );
        initialDateRange = DateTimeRange(
          start: startDate,
          end: startDate.add(const Duration(days: 1)),
        );
      }
    } else {
      DateTime? startDate;
      DateTime? endDate;

      for (int i = 0; i < previousApplied.length; i++) {
        if (previousApplied[i].filterTitle.contains('from_date')) {
          startDate = core.DateUtil.stringToDate(
            previousApplied[i].filterKey,
            inputDateFormat.pattern!,
          );
        } else if (previousApplied[i].filterTitle.contains('to_date')) {
          endDate = core.DateUtil.stringToDate(
            previousApplied[i].filterKey,
            inputDateFormat.pattern!,
          );
        }
      }
      initialDateRange = DateTimeRange(start: startDate!, end: endDate!);
    }

    final TextEditingController textEditingController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 10,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Expanded(child: Text(title))],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 0.0,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTimeRange? picked =
                            await showDateRangePickerDialog(
                              context: context,
                              initialDateRange: initialDateRange,
                              firstDate: minimumDate,
                              lastDate: maximumDate,
                              cancelText: textButtonCancel,
                              confirmText: textButtonOkay,
                              helpText: helpText,
                            );
                        if (picked != null && picked != initialDateRange) {
                          setState(() {
                            initialDateRange = picked;
                            textEditingController.text =
                                '${inputDateFormat.format(picked.start)} - ${inputDateFormat.format(picked.end)}';

                            final FilterItemModel startModel = FilterItemModel(
                              filterKey: inputDateFormat.format(picked.start),
                              filterTitle: 'from_date',
                            );
                            final FilterItemModel endModel = FilterItemModel(
                              filterKey: inputDateFormat.format(picked.end),
                              filterTitle: 'to_date',
                            );
                            final List<FilterItemModel> list =
                                <FilterItemModel>[startModel, endModel];
                            core.PlatformUtils.debugLog(
                              FilterWidget,
                              'rangeDatePickerWidget:onTap:${list.toString()}',
                            );
                            context.read<FilterCubit>().onFilterItemCheck(list);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: textEditingController,
                          decoration: InputDecoration(
                            labelText: labelText,
                            hintText: hintText,
                            suffixIcon: textEditingController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        textEditingController.clear();
                                        initialDateRange = null;
                                        context
                                            .read<FilterCubit>()
                                            .onFilterItemCheck(<dynamic>[]);
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).disabledColor,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder rangeTimePickerWidget(
    FilterState state,
    ThemeProps? themeProps,
  ) {
    final List<FilterItemModel> previousApplied =
        state.filters![state.activeFilterIndex].previousApplied;

    final String title = state.filters![state.activeFilterIndex].title ?? '';

    final DateFormat inputDateFormat =
        state.filters![state.activeFilterIndex].inputDateFormat ??
        DateFormat('hh:mm:ss aaa');

    final DateTime minimumDate =
        state.filters![state.activeFilterIndex].minimumDate ??
        DateTime(
          DateTime.now().year,
          1,
          1,
          DateTime.now().hour,
          DateTime.now().minute,
          DateTime.now().second,
        );

    final DateTime maximumDate =
        state.filters![state.activeFilterIndex].maximumDate ??
        DateTime(
          DateTime.now().year,
          1,
          1,
          DateTime.now().hour + 1,
          DateTime.now().minute,
          DateTime.now().second,
        );

    final String labelText =
        state.filters![state.activeFilterIndex].labelText ?? '';
    final String hintText =
        state.filters![state.activeFilterIndex].hintText ?? '';
    final String helpText =
        state.filters![state.activeFilterIndex].helpText ?? '';
    final String? textButtonCancel =
        state.filters![state.activeFilterIndex].textButtonCancel;
    final String? textButtonOkay =
        state.filters![state.activeFilterIndex].textButtonOkay;

    DateTimeRange? initialDateRange;
    if (previousApplied.isEmpty) {
      final String? initialDate =
          state.filters![state.activeFilterIndex].initialDate;
      if (initialDate != null && initialDate.isNotEmpty) {
        final DateTime startDate = core.DateUtil.stringToDate(
          initialDate,
          inputDateFormat.pattern!,
        );
        initialDateRange = DateTimeRange(
          start: startDate,
          end: startDate.add(const Duration(hours: 1)),
        );
      } else {
        final DateTime now = DateTime.now();
        initialDateRange = DateTimeRange(
          start: now,
          end: now.add(const Duration(hours: 1)),
        );
      }
    } else {
      DateTime? startDate;
      DateTime? endDate;

      for (int i = 0; i < previousApplied.length; i++) {
        if (previousApplied[i].filterTitle.contains('from_date')) {
          startDate = core.DateUtil.stringToDate(
            previousApplied.first.filterKey,
            inputDateFormat.pattern!,
          );
        } else if (previousApplied[i].filterTitle.contains('to_date')) {
          endDate = core.DateUtil.stringToDate(
            previousApplied.last.filterKey,
            inputDateFormat.pattern!,
          );
        }
      }
      initialDateRange = DateTimeRange(start: startDate!, end: endDate!);
    }

    final TextEditingController textEditingController = TextEditingController();

    return StatefulBuilder(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 10,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Expanded(child: Text(title))],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 0.0,
                bottom: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTimeRange? picked =
                            await showTimeRangePickerDialog(
                              context: context,
                              initialDateRange: initialDateRange,
                              firstDate: minimumDate,
                              lastDate: maximumDate,
                              cancelText: textButtonCancel,
                              confirmText: textButtonOkay,
                              helpText: helpText,
                            );
                        if (picked != null && picked != initialDateRange) {
                          initialDateRange = picked;
                          textEditingController.text =
                              '${inputDateFormat.format(picked.start)} - ${inputDateFormat.format(picked.end)}';

                          final FilterItemModel startModel = FilterItemModel(
                            filterKey: inputDateFormat.format(picked.start),
                            filterTitle: 'from_date',
                          );
                          final FilterItemModel endModel = FilterItemModel(
                            filterKey: inputDateFormat.format(picked.end),
                            filterTitle: 'to_date',
                          );
                          final List<FilterItemModel> list =
                              <FilterItemModel>[];
                          list.add(startModel);
                          list.add(endModel);
                          core.PlatformUtils.debugLog(
                            FilterWidget,
                            'rangeDatePickerWidget:onTap:${list.toString()}',
                          );
                          if (!context.mounted) return;
                          await context.read<FilterCubit>().onFilterItemCheck(
                            list,
                          );
                          setState(() {});
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: textEditingController,
                          decoration: InputDecoration(
                            labelText: labelText,
                            hintText: hintText,
                            suffixIcon: textEditingController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () async {
                                      setState(() {
                                        textEditingController.clear();
                                        initialDateRange = null;
                                        context
                                            .read<FilterCubit>()
                                            .onFilterItemCheck(null);
                                      });
                                      state(() {});
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).disabledColor,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<DateTimeRange?> showDateRangePickerDialog({
    required BuildContext context,
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
    String? cancelText,
    String? confirmText,
    String? helpText,
  }) async {
    return showDateRangePicker(
      context: context,
      currentDate: DateTime.now(),
      initialDateRange: initialDateRange,
      firstDate: firstDate ?? DateTime(DateTime.now().year - 5),
      lastDate: lastDate ?? DateTime(DateTime.now().year + 5),
      cancelText: cancelText,
      confirmText: confirmText,
      helpText: helpText,
    );
  }

  Future<DateTimeRange?> showTimeRangePickerDialog({
    required BuildContext context,
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
    String? cancelText,
    String? confirmText,
    String? helpText,
  }) async {
    return showTimeRangePickerDialog(
      context: context,
      initialDateRange: initialDateRange,
      helpText: helpText,
      confirmText: confirmText,
      cancelText: cancelText,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  @override
  void dispose() {
    _searchValueNotifier.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
