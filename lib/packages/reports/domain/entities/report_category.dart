import 'package:flutter/material.dart';

enum ReportType {
  dailySales,
  monthlySales,
  topSellingItems,
  paymentModes,
  salesDashboard,
  inventoryStock,
  purchases,
  expenditure,
  menuItemSales,
}

class ReportCategory {
  const ReportCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.icon = Icons.bar_chart_rounded,
    this.colorHex,
    this.filterItemName,
  });

  final String id;
  final String title;
  final String subtitle;
  final ReportType type;
  final IconData icon;
  final String? colorHex;
  final String? filterItemName;
}
