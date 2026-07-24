import '../props/filter_item_model.dart';
import '../props/filter_props.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

class FilterVerticalRangerSliderTitle extends StatefulWidget {
  const FilterVerticalRangerSliderTitle({
    required this.filterOptions,
    required this.previousApplied,
    required this.title,
    required this.values,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    super.key,
    this.sliderTileThemeProps,
  });
  final List<FilterItemModel> filterOptions;
  final List<FilterItemModel> previousApplied;
  final String title;
  final SfRangeValues? values;
  final double minValue;
  final double maxValue;
  final Function(SfRangeValues) onChanged;
  final SliderTileThemeProps? sliderTileThemeProps;

  @override
  FilterVerticalRangerSliderTitleState createState() =>
      FilterVerticalRangerSliderTitleState();
}

class FilterVerticalRangerSliderTitleState
    extends State<FilterVerticalRangerSliderTitle> {
  SfRangeValues? _values;

  @override
  void initState() {
    super.initState();
    _values = widget.values ?? SfRangeValues(widget.minValue, widget.maxValue);
  }

  @override
  void didUpdateWidget(FilterVerticalRangerSliderTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.values != oldWidget.values) {
      setState(() {
        _values =
            widget.values ?? SfRangeValues(widget.minValue, widget.maxValue);
      });
    }
    core.PlatformUtils.debugLog(
      FilterVerticalRangerSliderTitle,
      'didUpdateWidget called',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    core.PlatformUtils.debugLog(
      FilterVerticalRangerSliderTitle,
      'didChangeDependencies called',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Text(widget.title),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                  child: Visibility(
                    visible:
                        widget.sliderTileThemeProps?.sliderThemeData != null,
                    replacement: slider(),
                    child: SfRangeSliderTheme(
                      data:
                          widget.sliderTileThemeProps?.sliderThemeData ??
                          const SfRangeSliderThemeData(),
                      child: slider(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget slider() {
    return SfRangeSlider.vertical(
      tooltipTextFormatterCallback: (value, formattedText) =>
          '${(widget.sliderTileThemeProps?.tooltipPrefixStr == null || widget.sliderTileThemeProps!.tooltipPrefixStr!.isEmpty) ? "" : "${widget.sliderTileThemeProps?.tooltipPrefixStr.toString()} "}${double.tryParse("$value")?.toStringAsFixed(widget.sliderTileThemeProps?.fractionDigits ?? 0) ?? 0}${(widget.sliderTileThemeProps?.tooltipSuffixStr == null || widget.sliderTileThemeProps!.tooltipSuffixStr!.isEmpty) ? "" : " ${widget.sliderTileThemeProps?.tooltipSuffixStr}"}',
      min: widget.minValue,
      max: widget.maxValue,
      values: _values ?? SfRangeValues(widget.minValue, widget.maxValue),
      stepSize: widget.sliderTileThemeProps?.stepSize ?? 1.0,
      showLabels: true,
      enableTooltip: true,
      labelFormatterCallback: (value, formattedText) {
        return '${(widget.sliderTileThemeProps?.labelPrefixStr == null || widget.sliderTileThemeProps!.labelPrefixStr!.isEmpty) ? "" : "${widget.sliderTileThemeProps?.labelPrefixStr.toString()} "}${double.tryParse("$value")?.toStringAsFixed(widget.sliderTileThemeProps?.fractionDigits ?? 0) ?? 0}${(widget.sliderTileThemeProps?.labelSuffixStr == null || widget.sliderTileThemeProps!.labelSuffixStr!.isEmpty) ? "" : " ${widget.sliderTileThemeProps?.labelSuffixStr.toString()}"}';
      },
      onChanged: (SfRangeValues newValues) {
        setState(() {
          _values = newValues;
        });
        widget.onChanged(newValues);
      },
    );
  }
}
