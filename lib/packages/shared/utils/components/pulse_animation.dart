import 'package:flutter/material.dart';

class PulseAnimation extends StatefulWidget {
  const PulseAnimation({
    required this.child,
    super.key,
    this.minScale = 0.9,
    this.maxScale = 1.1,
    this.duration = 500,
  });
  final Widget child;
  final double minScale;
  final double maxScale;
  final int duration;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );
    _scaleAnimation =
        Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if any of the dependencies have changed
    if (widget.minScale != _scaleAnimation.value ||
        widget.maxScale != _scaleAnimation.value ||
        widget.duration != _animationController.duration!.inMilliseconds) {
      // Dispose the old animation controller and create a new one with the updated values
      _animationController.dispose();
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.duration),
      );
      _scaleAnimation =
          Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
      _animationController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
