import 'dart:math';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class SplashScreenTabletLayout extends StatefulWidget {
  const SplashScreenTabletLayout({super.key});

  @override
  State<SplashScreenTabletLayout> createState() =>
      _SplashScreenTabletLayoutState();
}

class _SplashScreenTabletLayoutState extends State<SplashScreenTabletLayout> {
  List<Color> listParticleColor = <Color>[];
  late Image appLogoLight;

  Size? size;
  Orientation? orientation;

  @override
  void initState() {
    appLogoLight = Image.asset(
      Assets.images.appLogoClearBg.path,
      fit: BoxFit.scaleDown,
      width: 250,
      height: 250,
    );
    super.initState();

    final cafeParticlePalette = <Color>[
      const Color(0xffff8a5c), // Primary bright coral/peach
      const Color(0xfff59e0b), // Warm caramel amber
      const Color(0xfffbbf24), // Amber gold
      const Color(0xffffb59c), // Light peach
      const Color(0xffdebfa8), // Warm latte
      const Color(0xffe7bdb2), // Creamy mocha
      const Color(0xffcb4a00), // Roasted cinnamon
      const Color(0xffffffff), // Soft white highlight
    ];
    for (int i = 0; i < 50; i++) {
      listParticleColor.add(
        cafeParticlePalette[Random().nextInt(cafeParticlePalette.length)],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    orientation = MediaQuery.of(context).orientation;
    return AnimateGradient(
      primaryBegin: Alignment.topLeft,
      primaryEnd: Alignment.bottomRight,
      secondaryBegin: Alignment.bottomLeft,
      secondaryEnd: Alignment.topRight,
      duration: const Duration(seconds: 4),
      primaryColors: const <Color>[
        Color(0xff1c110c),
        Color(0xff291811),
      ],
      secondaryColors: const <Color>[
        Color(0xff24140d),
        Color(0xff120a06),
      ],
      child: SizedBox(
        key: UniqueKey(),
        width: size!.width,
        height: size!.height,
        child: Stack(
          children: <Widget>[
            CircularParticle(
              awayRadius: 50,
              numberOfParticles: 120,
              speedOfParticles: 1.3,
              width: size!.width,
              height: size!.height,
              onTapAnimation: true,
              particleColor: const Color(0xffffb59c).withValues(alpha: 0.5),
              awayAnimationDuration: const Duration(milliseconds: 600),
              maxParticleSize: 8,
              isRandSize: true,
              isRandomColor: true,
              randColorList: listParticleColor,
              awayAnimationCurve: Curves.easeInOutBack,
              enableHover: true,
              hoverColor: const Color(0xffff8a5c),
              hoverRadius: 90,
              connectDots: false, //not recommended
            ),
            PositionedDirectional(
              top: 0,
              bottom: 0,
              start: 0,
              end: 0,
              child: OrientationBuilder(
                builder: (context, orientation) {
                  return Center(
                    child: PulseAnimation(
                      maxScale: 1.0,
                      minScale: 0.9,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xff241712).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xffffb49a)
                                .withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff000000)
                                  .withValues(alpha: 0.45),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: const Color(0xffff8a5c)
                                  .withValues(alpha: 0.12),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: appLogoLight,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    precacheImage(appLogoLight.image, context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
