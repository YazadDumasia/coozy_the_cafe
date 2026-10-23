import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';

class SuccessfullyScreen extends StatefulWidget {
  final String redirectPath;

  const SuccessfullyScreen({super.key, required this.redirectPath});

  @override
  State<SuccessfullyScreen> createState() => _SuccessfullyScreenState();
}

class _SuccessfullyScreenState extends State<SuccessfullyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double lottieDimension = 200.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lottieAsset = isDark
        ? Assets.lottie.successDark
        : Assets.lottie.successLight;

    final gradientColors = AnimateGradientColors.of(context);
    final particleColors = AnimateGradientColors.getCafeParticlePalette(context);
    final size = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimateGradient(
          primaryBegin: Alignment.topLeft,
          primaryEnd: Alignment.bottomRight,
          secondaryBegin: Alignment.bottomLeft,
          secondaryEnd: Alignment.topRight,
          duration: const Duration(seconds: 4),
          primaryColors: gradientColors.primaryColors,
          secondaryColors: gradientColors.secondaryColors,
          child: Stack(
            children: [
              CircularParticle(
                width: size.width,
                height: size.height,
                awayRadius: 60,
                numberOfParticles: 90,
                speedOfParticles: 1.2,
                maxParticleSize: 7,
                particleColor: (isDark ? const Color(0xffffb59c) : const Color(0xff8c5338))
                    .withValues(alpha: 0.4),
                isRandSize: true,
                isRandomColor: true,
                randColorList: particleColors,
                awayAnimationDuration: const Duration(milliseconds: 600),
                awayAnimationCurve: Curves.easeInOutBack,
                enableHover: true,
                hoverColor: const Color(0xffff8a5c),
                hoverRadius: 80,
                onTapAnimation: true,
                connectDots: false,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      lottieAsset,
                      controller: _controller,
                      onLoaded: (composition) {
                        _controller
                          ..duration = composition.duration
                          ..forward().whenComplete(() {
                            // Navigate to home screen after animation completes
                            if (mounted) {
                              context.go(widget.redirectPath);
                            }
                          });
                      },
                      width: lottieDimension,
                      height: lottieDimension,
                      repeat: false,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr(
                            LocaleKeys.successfullyScreenSuccessfullyVerified,
                            track: TrackConstants.successfullyScreenTrack,
                          ) ??
                          'Successfully Verified!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
