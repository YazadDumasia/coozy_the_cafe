import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class ComboStepInfo {
  final int stepIndex;
  final String title;
  final String subtitle;
  final IconData icon;

  const ComboStepInfo({
    required this.stepIndex,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Tablet Stepper: Inspired by Image 3 Style 01 (segmented pills with arrow chevrons)
class TabletSegmentedStepper extends StatelessWidget {
  final int activeIndex;
  final List<ComboStepInfo> steps;
  final ValueChanged<int>? onStepTapped;

  const TabletSegmentedStepper({
    super.key,
    required this.activeIndex,
    required this.steps,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.tr(
                      shared.LocaleKeys.comboFormDialogTabletHeader,
                      track: shared.TrackConstants.comboPageTrack,
                    ) ??
                    'COMBO / BUNDLE CONFIGURATION',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                context.tr(
                      shared.LocaleKeys.comboFormDialogStepIndicator,
                      track: shared.TrackConstants.comboPageTrack,
                      params: {
                        'current': (activeIndex + 1).toString(),
                        'total': steps.length.toString(),
                      },
                    ) ??
                    'Step ${activeIndex + 1} of ${steps.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isActive = index == activeIndex;
              final isCompleted = index < activeIndex;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < steps.length - 1 ? 8.0 : 0,
                  ),
                  child: InkWell(
                    onTap: onStepTapped != null
                        ? () => onStepTapped!(index)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primary
                            : isCompleted
                            ? colorScheme.primaryContainer.withValues(
                                alpha: 0.35,
                              )
                            : colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? colorScheme.primary
                              : isCompleted
                              ? colorScheme.primary.withValues(alpha: 0.4)
                              : colorScheme.outlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                          width: isActive ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? colorScheme.onPrimary
                                  : isCompleted
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.12,
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: colorScheme.onPrimary,
                                    )
                                  : Text(
                                      '0${index + 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? colorScheme.primary
                                            : colorScheme.onSurface.withValues(
                                                alpha: 0.7,
                                              ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  step.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  step.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: isActive
                                        ? colorScheme.onPrimary.withValues(
                                            alpha: 0.85,
                                          )
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.6,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Mobile Stepper: Inspired by Image 1 & Image 3 Style 04 (Icons, Active Glow & Progress Line)
class MobileIconStepper extends StatelessWidget {
  final int activeIndex;
  final List<ComboStepInfo> steps;
  final ValueChanged<int>? onStepTapped;

  const MobileIconStepper({
    super.key,
    required this.activeIndex,
    required this.steps,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (activeIndex + 1) / steps.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step circles with icons and connecting line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isActive = index == activeIndex;
              final isCompleted = index < activeIndex;

              return Expanded(
                child: Row(
                  children: [
                    // Step item (icon + title underneath)
                    GestureDetector(
                      onTap: onStepTapped != null
                          ? () => onStepTapped!(index)
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? colorScheme.primary
                                  : isCompleted
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.4),
                              border: Border.all(
                                color: isActive
                                    ? colorScheme.primary
                                    : isCompleted
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant.withValues(
                                        alpha: 0.5,
                                      ),
                                width: isActive ? 2.5 : 1.2,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: colorScheme.primary,
                                    )
                                  : Icon(
                                      step.icon,
                                      size: 18,
                                      color: isActive
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface.withValues(
                                              alpha: 0.5,
                                            ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.title,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isActive
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.65,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Connector line between steps
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: index < activeIndex
                                ? colorScheme.primary
                                : colorScheme.outlineVariant.withValues(
                                    alpha: 0.35,
                                  ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // Linear progress bar indicator (like Image 1 top progress bar)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Web Stepper Sidebar: Inspired by Image 2 (left column sidebar with clean vertical step trail)
class WebStepperSidebar extends StatelessWidget {
  final int activeIndex;
  final List<ComboStepInfo> steps;
  final ValueChanged<int>? onStepTapped;
  final bool isEditMode;

  const WebStepperSidebar({
    super.key,
    required this.activeIndex,
    required this.steps,
    this.onStepTapped,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cafe Branding Logo / Icon
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.fastfood_rounded,
                    color: colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                          shared.LocaleKeys.comboFormDialogWebBrandTitle,
                          track: shared.TrackConstants.comboPageTrack,
                        ) ??
                        'Coozy Promotions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    context.tr(
                          shared.LocaleKeys.comboFormDialogWebBrandSubtitle,
                          track: shared.TrackConstants.comboPageTrack,
                        ) ??
                        'Bundle Creator',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Main Header & Subtitle
          Text(
            context.tr(
                  shared.LocaleKeys.comboFormDialogWebSidebarTitle,
                  track: shared.TrackConstants.comboPageTrack,
                ) ??
                'Combo Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
                  shared.LocaleKeys.comboFormDialogWebSidebarSubtitle,
                  track: shared.TrackConstants.comboPageTrack,
                ) ??
                "We're setting up your combo and bundle offer for your cafe menu.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 40),

          // Vertical Stepper Trail
          Expanded(
            child: ListView.builder(
              itemCount: steps.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final step = steps[index];
                final isActive = index == activeIndex;
                final isCompleted = index < activeIndex;
                final isLast = index == steps.length - 1;

                return InkWell(
                  onTap: onStepTapped != null
                      ? () => onStepTapped!(index)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Node circle and connector line
                      Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? colorScheme.primary
                                  : isActive
                                  ? colorScheme.surface
                                  : colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.4),
                              border: Border.all(
                                color: isActive
                                    ? colorScheme.primary
                                    : isCompleted
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant.withValues(
                                        alpha: 0.6,
                                      ),
                                width: isActive ? 2.5 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: colorScheme.onPrimary,
                                    )
                                  : isActive
                                  ? Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colorScheme.primary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 52,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: isCompleted
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant.withValues(
                                      alpha: 0.35,
                                    ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Text label and subtitle
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isActive
                                      ? colorScheme.primary
                                      : isCompleted
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step.subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isActive
                                      ? colorScheme.onSurface.withValues(
                                          alpha: 0.75,
                                        )
                                      : colorScheme.onSurface.withValues(
                                          alpha: 0.45,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Footer link / info
          Text(
            'coozy.thecafe.internal',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
