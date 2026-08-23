import 'package:flutter/material.dart';

class SubcategoryHeaderWidget extends StatelessWidget {
  final String title;

  const SubcategoryHeaderWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const EdgeInsets headerPadding = EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    );
    const EdgeInsets headerMargin = EdgeInsets.only(top: 12.0, bottom: 6.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.4);

    return Container(
      width: double.infinity,
      padding: headerPadding,
      margin: headerMargin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
