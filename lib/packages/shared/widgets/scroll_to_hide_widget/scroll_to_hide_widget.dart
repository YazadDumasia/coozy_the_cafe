import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollToHideWidget extends StatefulWidget {
  const ScrollToHideWidget({
    required this.child,
    required this.controller,
    super.key,
    this.duration = const Duration(milliseconds: 200),
  });
  final Widget child;
  final ScrollController controller;
  final Duration duration;

  @override
  State<ScrollToHideWidget> createState() => _ScrollToHideWidgetState();
}

class _ScrollToHideWidgetState extends State<ScrollToHideWidget> {
  final ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listen);
  }

  @override
  void dispose() {
    widget.controller.removeListener(listen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isVisible,
      builder: (context, isVisible, child) {
        return AnimatedContainer(
          duration: widget.duration,
          height: isVisible ? null : 0,
          child: Wrap(children: <Widget>[widget.child]),
        );
      },
    );
  }

  void listen() {
    final ScrollDirection direction =
        widget.controller.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      show();
    } else if (direction == ScrollDirection.reverse) {
      hide();
    }
  }

  void show() {
    if (isVisible.value == false) {
      isVisible.value = true;
    }
  }

  void hide() {
    if (isVisible.value == true) {
      isVisible.value = false;
    }
  }
}
