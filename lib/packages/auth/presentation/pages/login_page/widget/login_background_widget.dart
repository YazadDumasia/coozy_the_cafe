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
    return shared.AnimateGradient(
      primaryBegin: Alignment.topLeft,
      primaryEnd: Alignment.bottomLeft,
      secondaryBegin: Alignment.bottomLeft,
      secondaryEnd: Alignment.topRight,
      duration: const Duration(seconds: 2),
      primaryColors: const <Color>[
        Color.fromRGBO(225, 109, 245, 1),
        Color.fromRGBO(78, 248, 231, 1),
      ],
      secondaryColors: const <Color>[
        Color.fromRGBO(5, 222, 250, 1),
        Color.fromRGBO(134, 231, 214, 1),
      ],
      child: SizedBox(
        key: UniqueKey(),
        width: size.width,
        height: size.height,
        child: Stack(
          children: <Widget>[
            shared.CircularParticle(
              awayRadius: 100,
              numberOfParticles: 250,
              connectDots: false,
              enableHover: false,
              hoverColor: Theme.of(context).colorScheme.secondary,
              hoverRadius: 50,
              speedOfParticles: 1.3,
              width: size.width,
              height: size.height,
              onTapAnimation: true,
              particleColor: Colors.white.withAlpha(150),
              awayAnimationDuration: const Duration(milliseconds: 600),
              maxParticleSize: 8,
              isRandSize: true,
              isRandomColor: true,
              randColorList: widget.listParticleColor ?? [],
              awayAnimationCurve: Curves.easeInOutBack,
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
