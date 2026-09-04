import 'dart:async';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_floating_particles/flutter_floating_particles.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessView extends StatefulWidget {
  final double grandTotal;
  final String receiptId;
  final int itemCount;
  final VoidCallback? onGetReceipt;
  final VoidCallback? onNewSale;

  const PaymentSuccessView({
    super.key,
    required this.grandTotal,
    this.receiptId = '',
    this.itemCount = 0,
    this.onGetReceipt,
    this.onNewSale,
  });

  static final ParticleConfig confettiConfig = ParticleConfig(
    particleType: ParticleType.square,
    direction: ParticleDirection.topToBottom,
    particleCoverage: ParticleCoverage.semiFull,
    particleCount: 50,
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
    particleCount: 30,
    minSize: 3.0,
    maxSize: 8.0,
    gradientColors: const [Colors.white, Colors.yellow, Colors.lightBlue],
    enableGlow: true,
    glowRadius: 5.0,
    enableRotation: true,
    velocityMultiplier: 0.8,
    animationDuration: const Duration(seconds: 25),
    minOpacity: 0.5,
    maxOpacity: 1.0,
  );

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  final ValueNotifier<bool> _isParticleEnabledNotifier =
      ValueNotifier<bool>(true);
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
    _disableTimer = Timer(const Duration(seconds: 5), () {
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

  void _handleBackToHome() {
    if (widget.onNewSale != null) {
      widget.onNewSale!();
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      context.go(core.AppRoutePath.homeRoute);
    }
  }

  Widget _buildSuccessContent(
    BuildContext context, {
    required double maxWidth,
    required bool isElevatedCard,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formattedAmount = core.CurrencyFormatter.format(value: widget.grandTotal);

    final lottieAssetPath = isDark
        ? 'assets/lottie/success_dark.json'
        : 'assets/lottie/success_light.json';

    final mainColumn = Column(
      children: [
        // Main Centered Content: Lottie Animation & Grand Total
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                lottieAssetPath,
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController
                    ..duration = composition.duration
                    ..forward();
                },
                width: isElevatedCard ? 220 : 180,
                height: isElevatedCard ? 220 : 180,
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  _scheduleDisableTimer();
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF5CB85C),
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 70,
                      color: Color(0xFF5CB85C),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                formattedAmount,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Bottom Section: Info Row & Action Buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: isElevatedCard ? BorderRadius.circular(16) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Receipt ID & Item Count Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(
                          shared.LocaleKeys.checkoutReceiptId,
                          track: shared.TrackConstants.checkoutPageTrack,
                          params: {'receiptId': widget.receiptId},
                        ) ??
                        'RECEIPT ID: ${widget.receiptId}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    context.tr(
                          shared.LocaleKeys.checkoutItemCount,
                          track: shared.TrackConstants.checkoutPageTrack,
                          params: {'count': widget.itemCount.toString()},
                        ) ??
                        'ITEM COUNT: ${widget.itemCount}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Green Button: GET RECEIPT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      widget.onGetReceipt ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receipt downloaded')),
                        );
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5CB85C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 1,
                  ),
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.checkoutGetReceipt,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'GET RECEIPT',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Purple Button: NEW SALE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleBackToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 1,
                  ),
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.checkoutNewSale,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'NEW SALE',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (isElevatedCard) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: mainColumn,
              ),
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: mainColumn,
    );
  }

  Widget _buildParticleLayer({required Widget child}) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isParticleEnabledNotifier,
      builder: (context, isEnabled, childWidget) {
        return ParticleEffects(
          config: PaymentSuccessView.confettiConfig,
          isEnabled: isEnabled,
          child: ParticleEffects(
            config: PaymentSuccessView.starsConfig,
            isEnabled: isEnabled,
            child: childWidget!,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackToHome();
      },
      child: _buildParticleLayer(
        child: Container(
          color: theme.colorScheme.surface,
          width: double.infinity,
          alignment: Alignment.center,
          child: SafeArea(
            child: shared.ResponsiveLayout(
              mobile: _buildSuccessContent(
                context,
                maxWidth: double.infinity,
                isElevatedCard: false,
              ),
              tablet: _buildSuccessContent(
                context,
                maxWidth: 540,
                isElevatedCard: true,
              ),
              desktop: _buildSuccessContent(
                context,
                maxWidth: 640,
                isElevatedCard: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
