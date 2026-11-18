import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class ComboReorderEmptyView extends StatelessWidget {
  const ComboReorderEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sort_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr(
                    shared.LocaleKeys.comboReorderPageEmptyTitle,
                    track: shared.TrackConstants.comboPageTrack,
                  ) ??
                  'No Combos to Reorder',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                context.tr(
                      shared.LocaleKeys.comboReorderPageEmptySubtitle,
                      track: shared.TrackConstants.comboPageTrack,
                    ) ??
                    'Create combos first before reordering their sequence.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
