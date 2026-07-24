// ignore_for_file: library_private_types_in_public_api
import 'dart:ui';

import 'package:flutter/material.dart';

class BlurWidget extends StatefulWidget {
  const BlurWidget({super.key, this.child, this.sigmaX = 10, this.sigmaY = 10});
  final Widget? child;
  final double? sigmaX;
  final double? sigmaY;

  @override
  State<BlurWidget> createState() => _BlurWidgetState();
}

class _BlurWidgetState extends State<BlurWidget> {
  double? _sigmaX;
  double? _sigmaY;

  @override
  void initState() {
    super.initState();
    _sigmaX = widget.sigmaX;
    _sigmaY = widget.sigmaY;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: _sigmaX ?? 0.0, sigmaY: _sigmaY ?? 0.0),
      child: widget.child,
    );
  }
}
