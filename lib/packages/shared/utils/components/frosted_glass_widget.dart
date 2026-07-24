import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedGlassWidget extends StatelessWidget {
  const FrostedGlassWidget({
    required this.child,
    super.key,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
    this.opacity = 0.1,
  });
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }
}
