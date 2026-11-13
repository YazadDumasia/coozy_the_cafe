import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class CombosTabEmptyView extends StatelessWidget {
  final VoidCallback? onReviewOrder;

  const CombosTabEmptyView({super.key, this.onReviewOrder});

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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Combos Available',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                'There are no active combo meals or promotional deals matching your search right now.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onReviewOrder != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onReviewOrder,
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: Text(
                  context.tr(
                        shared.LocaleKeys.reviewOrderBtnText,
                        track: shared.TrackConstants.tablePageTrack,
                      ) ??
                      'Review Order',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
