import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import '../props/filter_item_model.dart';
import '../props/filter_props.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class FilterSliderTitle extends StatefulWidget {
  const FilterSliderTitle({
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
  final double? values;
  final double minValue;
  final double maxValue;

  final Function(double) onChanged;
  final SliderTileThemeProps? sliderTileThemeProps;

  @override
  FilterSliderTitleState createState() => FilterSliderTitleState();
}

class FilterSliderTitleState extends State<FilterSliderTitle> {
  double? _values;

  @override
  void initState() {
    super.initState();
    _values = widget.values ?? 0;
    core.PlatformUtils.debugLog(
      FilterSliderTitle,
      'sliderTileThemeProps:${widget.sliderTileThemeProps.toString()}',
    );
  }

  @override
  void didUpdateWidget(FilterSliderTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.values != oldWidget.values) {
      setState(() {
        _values = widget.values ?? 0;
      });
    }
    core.PlatformUtils.debugLog(FilterSliderTitle, 'didUpdateWidget called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    core.PlatformUtils.debugLog(
      FilterSliderTitle,
      'didChangeDependencies called',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Text(widget.title),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                child: Visibility(
                  visible:
                      widget.sliderTileThemeProps == null ||
                      widget.sliderTileThemeProps?.sliderThemeData != null,
                  replacement: slider(),
                  child: SfRangeSliderTheme(
                    data:
                        widget.sliderTileThemeProps?.sliderThemeData ??
                        const SfRangeSliderThemeData(
                          inactiveTrackColor: Colors.grey,
                        ),
                    child: slider(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  StatefulBuilder slider() {
    return StatefulBuilder(
      builder: (context, state) {
        return SfSlider(
          tooltipTextFormatterCallback: (value, formattedText) =>
              '${(widget.sliderTileThemeProps?.tooltipPrefixStr == null || widget.sliderTileThemeProps!.tooltipPrefixStr!.isEmpty) ? "" : "${widget.sliderTileThemeProps?.tooltipPrefixStr.toString()} "}${double.tryParse("$value")?.toStringAsFixed(widget.sliderTileThemeProps?.fractionDigits ?? 0) ?? 0}${(widget.sliderTileThemeProps?.tooltipSuffixStr == null || widget.sliderTileThemeProps!.tooltipSuffixStr!.isEmpty) ? "" : " ${widget.sliderTileThemeProps?.tooltipSuffixStr}"}',
          min: widget.minValue,
          max: widget.maxValue,
          value: _values ?? 0.0,
          stepSize:
              double.tryParse(
                '${widget.sliderTileThemeProps?.stepSize ?? 1.0}',
              ) ??
              1.0,
          showLabels: true,
          enableTooltip: true,
          labelFormatterCallback: (value, formattedText) {
            return '${(widget.sliderTileThemeProps?.labelPrefixStr == null || widget.sliderTileThemeProps!.labelPrefixStr!.isEmpty) ? "" : "${widget.sliderTileThemeProps?.labelPrefixStr.toString()} "}${double.tryParse("$value")?.toStringAsFixed(widget.sliderTileThemeProps?.fractionDigits ?? 0) ?? 0}${(widget.sliderTileThemeProps?.labelSuffixStr == null || widget.sliderTileThemeProps!.labelSuffixStr!.isEmpty) ? "" : " ${widget.sliderTileThemeProps?.labelSuffixStr.toString()}"}';
          },
          onChanged: (newValues) async {
            core.PlatformUtils.debugLog(
              FilterSliderTitle,
              'onChanged:newValues:$newValues',
            );
            _values = newValues;
            widget.onChanged(newValues);
            state(() {});
            setState(() {});
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
