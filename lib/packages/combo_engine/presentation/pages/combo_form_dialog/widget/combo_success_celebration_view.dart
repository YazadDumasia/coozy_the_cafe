import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_floating_particles/flutter_floating_particles.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../../domain/entities/combo.dart';

class ComboSuccessCelebrationView extends StatefulWidget {
  final Combo combo;
  final bool isEditMode;
  final VoidCallback onDone;

  const ComboSuccessCelebrationView({
    super.key,
    required this.combo,
    required this.isEditMode,
    required this.onDone,
  });

  static final ParticleConfig confettiConfig = ParticleConfig(
    particleType: ParticleType.square,
    direction: ParticleDirection.topToBottom,
    particleCoverage: ParticleCoverage.semiFull,
    particleCount: 45,
    minSize: 4.0,
    maxSize: 8.0,
    gradientColors: const [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ],
    enableRotation: true,
    velocityMultiplier: 1.0,
    animationDuration: const Duration(seconds: 10),
    minOpacity: 0.8,
    maxOpacity: 1.0,
  );

  static final ParticleConfig starsConfig = ParticleConfig(
    particleType: ParticleType.star,
    direction: ParticleDirection.topToBottom,
    particleCoverage: ParticleCoverage.semiFull,
    particleCount: 25,
    minSize: 3.0,
    maxSize: 8.0,
    gradientColors: const [Colors.white, Colors.yellow, Colors.amber],
    enableGlow: true,
    glowRadius: 5.0,
    enableRotation: true,
    velocityMultiplier: 0.8,
    animationDuration: const Duration(seconds: 25),
    minOpacity: 0.5,
    maxOpacity: 1.0,
  );

  @override
  State<ComboSuccessCelebrationView> createState() =>
      _ComboSuccessCelebrationViewState();
}

class _ComboSuccessCelebrationViewState
    extends State<ComboSuccessCelebrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  final ValueNotifier<bool> _isParticleEnabledNotifier = ValueNotifier<bool>(
    true,
  );
  Timer? _disableTimer;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scheduleDisableTimer();
      }
    });
  }

  void _scheduleDisableTimer() {
    if (_disableTimer?.isActive ?? false) return;
    _disableTimer = Timer(const Duration(seconds: 4), () {
      _isParticleEnabledNotifier.value = false;
    });
  }

  @override
  void dispose() {
    _disableTimer?.cancel();
    _lottieController.dispose();
    _isParticleEnabledNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = shared.ResponsiveLayout.isMobile(context);

    final lottieAssetPath = isDark
        ? 'assets/lottie/success_dark.json'
        : 'assets/lottie/success_light.json';

    final titleText = widget.isEditMode
        ? (context.tr(
                shared.LocaleKeys.comboFormDialogSuccessUpdatedTitle,
                track: shared.TrackConstants.comboPageTrack,
              ) ??
              'Combo Updated Successfully!')
        : (context.tr(
                shared.LocaleKeys.comboFormDialogSuccessCreatedTitle,
                track: shared.TrackConstants.comboPageTrack,
              ) ??
              'Combo Created Successfully!');

    final subtitleText =
        context.tr(
          shared.LocaleKeys.comboFormDialogSuccessSubtitle,
          track: shared.TrackConstants.comboPageTrack,
          params: {'name': widget.combo.name},
        ) ??
        'Your combo offer "${widget.combo.name}" is ready for customers to order.';

    final itemsBadgeText =
        context.tr(
          shared.LocaleKeys.comboFormDialogSuccessItemsCount,
          track: shared.TrackConstants.comboPageTrack,
          params: {'count': widget.combo.items.length.toString()},
        ) ??
        '${widget.combo.items.length} Items Bundled';

    return Stack(
      children: [
        // Celebration floating particles
        ValueListenableBuilder<bool>(
          valueListenable: _isParticleEnabledNotifier,
          builder: (context, isEnabled, child) {
            return ParticleEffects(
              config: ComboSuccessCelebrationView.confettiConfig,
              isEnabled: isEnabled,
              child: ParticleEffects(
                config: ComboSuccessCelebrationView.starsConfig,
                isEnabled: isEnabled,
                child: const SizedBox.expand(),
              ),
            );
          },
        ),

        // Main Success Dialog Content
        Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 40,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lottie celebration tick animation
                  Lottie.asset(
                    lottieAssetPath,
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController
                        ..duration = composition.duration
                        ..forward();
                    },
                    width: isMobile ? 180 : 210,
                    height: isMobile ? 180 : 210,
                    repeat: false,
                    errorBuilder: (context, error, stackTrace) {
                      _scheduleDisableTimer();
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 4,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 70,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Headline Title
                  Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle offer description
                  Text(
                    subtitleText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Highlights Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.combo.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                itemsBadgeText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr(
                                    shared
                                        .LocaleKeys
                                        .comboFormDialogSuccessPriceLabel,
                                    track: shared.TrackConstants.comboPageTrack,
                                  ) ??
                                  'Special Combo Price:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            Text(
                              core.CurrencyFormatter.format(
                                value: widget.combo.sellingPrice,
                              ),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Done button to pop modal
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: widget.onDone,
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        context.tr(
                              shared
                                  .LocaleKeys
                                  .comboFormDialogSuccessActionDone,
                              track: shared.TrackConstants.comboPageTrack,
                            ) ??
                            'Done',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
