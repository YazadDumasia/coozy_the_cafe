import 'dart:math';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class SplashScreenMobileLayout extends StatefulWidget {
  const SplashScreenMobileLayout({super.key});

  @override
  State<SplashScreenMobileLayout> createState() =>
      _SplashScreenMobileLayoutState();
}

class _SplashScreenMobileLayoutState extends State<SplashScreenMobileLayout>
    with SingleTickerProviderStateMixin {
  Size? size;
  Orientation? orientation;
  List<Color> listParticleColor = <Color>[];
  late Image appLogoLight;

  @override
  void initState() {
    appLogoLight = Image.asset(
      Assets.images.appLogoClearBg.path,
      fit: BoxFit.scaleDown,
      width: 150,
      height: 150,
    );
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
    super.initState();
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
              numberOfParticles: 110,
              speedOfParticles: 1.4,
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
                  final isLandscape = orientation == Orientation.landscape;
                  final logoSize = isLandscape
                      ? MediaQuery.sizeOf(context).width * 0.22
                      : 130.0;
                  return Center(
                    child: PulseAnimation(
                      maxScale: 1.0,
                      minScale: 0.88,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xff241712).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xffffb49a)
                                .withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff000000)
                                  .withValues(alpha: 0.45),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: const Color(0xffff8a5c)
                                  .withValues(alpha: 0.12),
                              blurRadius: 35,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: logoSize,
                          height: logoSize,
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
}
