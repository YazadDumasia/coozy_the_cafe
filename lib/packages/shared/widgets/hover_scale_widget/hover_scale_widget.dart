import 'package:flutter/material.dart';

class HoverScaleWidget extends StatefulWidget {
  const HoverScaleWidget({
    required this.child,
    super.key,
    this.scaleFactor = 0.9,
    this.duration = const Duration(milliseconds: 200),
  });
  final Widget? child;
  final double scaleFactor;
  final Duration duration;

  @override
  State<HoverScaleWidget> createState() => _HoverScaleWidgetState();
}

class _HoverScaleWidgetState extends State<HoverScaleWidget> {
  final ValueNotifier<bool> _isHovering = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _isHovering.value = true,
      onExit: (event) => _isHovering.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isHovering,
        builder: (context, isHovering, child) => AnimatedScale(
          duration: widget.duration,
          scale: isHovering ? widget.scaleFactor : 1.0,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _isHovering.dispose();
    super.dispose();
  }
}
