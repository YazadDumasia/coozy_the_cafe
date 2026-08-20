import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class MenuItemListSearchBar extends StatelessWidget {
  final SearchController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const MenuItemListSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: SearchBar(
        controller: controller,
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(
          Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        leading: Icon(
          Icons.search_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        hintText:
            context.tr(
              shared.LocaleKeys.menuItemPageSearchItems,
              track: shared.TrackConstants.menuItemPageTrack,
            ) ??
            'Search dish...',
        hintStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 14,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        onChanged: onChanged,
        trailing: [
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
