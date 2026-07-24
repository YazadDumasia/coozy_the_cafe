import 'package:flutter/material.dart';

class CustomerListMobileLayout extends StatelessWidget {
  final Widget bodyWidget;

  const CustomerListMobileLayout({super.key, required this.bodyWidget});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: bodyWidget);
  }
}
