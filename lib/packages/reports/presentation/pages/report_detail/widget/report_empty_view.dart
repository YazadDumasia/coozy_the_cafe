import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

/// A beautifully crafted, responsive empty state widget for Reports & Analytics.
///
/// Designed with dual-theme compatibility (Light & Dark mode), clean typography,
/// soft gradients, visual iconography, and an optional action button.
class ReportEmptyView extends StatelessWidget {
  const ReportEmptyView({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  /// Custom headline title. If null, defaults to localized report empty title.
  final String? title;

  /// Custom explanatory subtitle. If null, defaults to localized suggestion.
  final String? subtitle;

  /// Main icon displayed inside the stylized container. Defaults to [Icons.insights_rounded].
  final IconData? icon;

  /// Optional action button label (e.g., 'Refresh' or 'Reset Date Range').
  final String? actionLabel;

  /// Optional callback triggered when action button is tapped.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final resolvedTitle =
        title ??
        (context.tr(
              shared.LocaleKeys.reportPageEmptyData,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'No data found for the selected range');

    final resolvedSubtitle =
        subtitle ??
        (context.tr(
              shared.LocaleKeys.reportPageEmptySubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'No transactions or records match this period. Try selecting a broader date range or adjusting filters.');

    final isCompact = shared.ResponsiveLayout.isMobile(context);

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 24.0 : 36.0,
          vertical: 24.0,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Outer glow badge container
              Container(
                width: isCompact ? 96 : 112,
                height: isCompact ? 96 : 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      scheme.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                      scheme.primary.withValues(alpha: isDark ? 0.08 : 0.03),
                    ],
                  ),
                  border: Border.all(
                    color: scheme.primary.withValues(
                      alpha: isDark ? 0.35 : 0.20,
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon ?? Icons.bar_chart_rounded,
                    size: isCompact ? 44 : 52,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                resolvedTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                resolvedSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),

              // Optional Action Button (e.g. Refresh or Clear)
              if (onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    actionLabel ??
                        (context.tr(
                              shared.LocaleKeys.commonRefresh,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Refresh'),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
