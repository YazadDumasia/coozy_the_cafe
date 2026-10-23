import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class LoginBackgroundWidget extends StatefulWidget {
  final Widget child;
  final List<Color>? listParticleColor;

  const LoginBackgroundWidget({
    super.key,
    required this.child,
    this.listParticleColor,
  });

  @override
  State<LoginBackgroundWidget> createState() => _LoginBackgroundWidgetState();
}

class _LoginBackgroundWidgetState extends State<LoginBackgroundWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gradientColors = shared.AnimateGradientColors.of(context);
    final defaultParticleColors =
        shared.AnimateGradientColors.getCafeParticlePalette(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return shared.AnimateGradient(
      primaryBegin: Alignment.topLeft,
      primaryEnd: Alignment.bottomRight,
      secondaryBegin: Alignment.bottomLeft,
      secondaryEnd: Alignment.topRight,
      duration: const Duration(seconds: 4),
      primaryColors: gradientColors.primaryColors,
      secondaryColors: gradientColors.secondaryColors,
      child: SizedBox(
        key: UniqueKey(),
        width: size.width,
        height: size.height,
        child: Stack(
          children: <Widget>[
            shared.CircularParticle(
              awayRadius: 100,
              numberOfParticles: 200,
              connectDots: false,
              enableHover: false,
              hoverColor: Theme.of(context).colorScheme.primary,
              hoverRadius: 50,
              speedOfParticles: 1.3,
              width: size.width,
              height: size.height,
              onTapAnimation: true,
              particleColor: isDark
                  ? const Color(0xffffb59c).withValues(alpha: 0.4)
                  : const Color(0xffa43c12).withValues(alpha: 0.3),
              awayAnimationDuration: const Duration(milliseconds: 600),
              maxParticleSize: 8,
              isRandSize: true,
              isRandomColor: true,
              randColorList: widget.listParticleColor?.isNotEmpty == true
                  ? widget.listParticleColor!
                  : defaultParticleColors,
              awayAnimationCurve: Curves.easeInOutBack,
            ),
            PositionedDirectional(
              top: 0,
              bottom: 0,
              start: 0,
              end: 0,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
