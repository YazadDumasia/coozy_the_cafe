import 'package:flutter/material.dart';

class CustomerListTabletLayout extends StatelessWidget {
  final Widget bodyWidget;

  const CustomerListTabletLayout({super.key, required this.bodyWidget});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: bodyWidget,
        ),
      ),
    );
  }
}
