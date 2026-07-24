import 'package:flutter/material.dart';

class WobbleAnimationWidget extends StatefulWidget {
  const WobbleAnimationWidget({required this.child, super.key});
  final Widget child;

  @override
  State<WobbleAnimationWidget> createState() => _WobbleAnimationWidgetState();
}

class _WobbleAnimationWidgetState extends State<WobbleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  late final Animation<double> _animation = Tween<double>(
    begin: -0.05,
    end: 0.05,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(angle: _animation.value, child: widget.child);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
