import 'package:flutter/material.dart';

class CustomerListDesktopLayout extends StatelessWidget {
  final Widget bodyWidget;

  const CustomerListDesktopLayout({super.key, required this.bodyWidget});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: bodyWidget,
        ),
      ),
    );
  }
}
