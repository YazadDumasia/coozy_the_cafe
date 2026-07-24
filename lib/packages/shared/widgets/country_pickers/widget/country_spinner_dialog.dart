// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';

// Typedefs
typedef Transformer<T> = String? Function(T item);

class ScrollPicker<T> extends StatefulWidget {
  ScrollPicker({
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.diameterRatio,
    super.key,
    this.showDivider = true,
    this.transformer,
    this.itemBuilder,
    FixedExtentScrollController? scrollController,
  }) : scrollController = scrollController ?? FixedExtentScrollController();

  final FixedExtentScrollController? scrollController;
  final double diameterRatio;

  // Events
  final ValueChanged<T> onChanged;

  // Variables
  final List<T> items;
  final T selectedItem;
  final bool showDivider;

  // Callbacks
  final Transformer<T>? transformer;

  // New callback: if provided, returns a custom widget for an item.
  final Widget Function(T item, bool isSelected)? itemBuilder;

  @override
  State<ScrollPicker<T>> createState() => _ScrollPickerState<T>();
}

class _ScrollPickerState<T> extends State<ScrollPicker<T>> {
  late T selectedValue;

  late FixedExtentScrollController scrollController;
  final GlobalKey _measurementKey = GlobalKey();
  double? autoItemHeight;
  final double fallbackItemHeight = 50.0;
  double widgetHeight = 0;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedItem;

    final int initialItem = widget.items.indexOf(selectedValue);
    scrollController =
        widget.scrollController ??
        FixedExtentScrollController(
          initialItem: initialItem >= 0 ? initialItem : 0,
        );
  }

  @override
  void didUpdateWidget(covariant ScrollPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Optionally re-measure if the items change.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureItemHeight());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    if (autoItemHeight == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureItemHeight());
    }

    // Use the auto-detected height if available, else fallback.
    final double effectiveItemHeight = autoItemHeight ?? fallbackItemHeight;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        widgetHeight = constraints.maxHeight;

        return LayoutBuilder(
          builder: (context, constraints) {
            widgetHeight = constraints.maxHeight;
            return Stack(
              children: <Widget>[
                GestureDetector(
                  onTapUp: _itemTapped,
                  child: ListWheelScrollView.useDelegate(
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: widget.items.length,
                      builder: (BuildContext context, int index) {
                        if (index < 0 || index > widget.items.length - 1) {
                          return null;
                        }

                        final value = widget.items[index];
                        bool isSelected = false;
                        try {
                          isSelected = (value == selectedValue);
                        } catch (e) {
                          isSelected = false;
                        }

                        if (index == 0) {
                          return Container(
                            key: _measurementKey,
                            child: widget.itemBuilder!(value, isSelected),
                          );
                        }
                        return widget.itemBuilder!(value, isSelected);
                      },
                    ),
                    controller: scrollController,
                    itemExtent: effectiveItemHeight,
                    diameterRatio: widget.diameterRatio,
                    onSelectedItemChanged: _onSelectedItemChanged,
                    physics: const FixedExtentScrollPhysics(),
                  ),
                ),
                Center(
                  child: widget.showDivider ? const Divider() : Container(),
                ),
                Center(
                  child: Container(
                    height: effectiveItemHeight + 10,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: themeData.colorScheme.secondary,
                          width: 2.0,
                        ),
                        bottom: BorderSide(
                          color: themeData.colorScheme.secondary,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Measures the height of the first item using its GlobalKey.
  void _measureItemHeight() {
    if (_measurementKey.currentContext != null) {
      final RenderBox box =
          _measurementKey.currentContext!.findRenderObject() as RenderBox;
      final double newHeight = box.size.height;
      if (newHeight > 0 &&
          (autoItemHeight == null || autoItemHeight != newHeight)) {
        setState(() {
          autoItemHeight = newHeight;
        });
      }
    }
  }

  void _itemTapped(TapUpDetails details) {
    final Offset position = details.localPosition;
    final double center = widgetHeight / 2;
    final double changeBy = position.dy - center;
    final double newPosition = scrollController.offset + changeBy;

    // animate to and center on the selected item
    scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onSelectedItemChanged(int index) {
    final T newValue = widget.items[index];
    if (newValue != selectedValue) {
      selectedValue = newValue;
      widget.onChanged(newValue);
    }
  }
}
