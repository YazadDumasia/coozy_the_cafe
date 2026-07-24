// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';

class HoverUpDownWidget extends StatefulWidget {
  const HoverUpDownWidget({
    required this.animationDuration,
    required this.childWidget,
    super.key,
  });
  final Duration? animationDuration;
  final Widget? childWidget;

  @override
  _HoverUpDownWidgetState createState() => _HoverUpDownWidgetState();
}

class _HoverUpDownWidgetState extends State<HoverUpDownWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.animationDuration ?? const Duration(seconds: 3),
  )..repeat(reverse: true);
  late final Animation<Offset> _animation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, 0.08),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.childWidget);
  }
}
