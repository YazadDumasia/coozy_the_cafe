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
    for (int i = 0; i < 50; i++) {
      listParticleColor.add(
        Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
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
      primaryEnd: Alignment.bottomLeft,
      secondaryBegin: Alignment.bottomLeft,
      secondaryEnd: Alignment.topRight,
      duration: const Duration(seconds: 2),
      primaryColors: const <Color>[
        Color.fromRGBO(225, 109, 245, 1),
        Color.fromRGBO(78, 248, 231, 1),
        // Color.fromRGBO(99, 251, 215, 1),
        // Color.fromRGBO(83, 138, 214, 1)
      ],
      secondaryColors: const <Color>[
        Color.fromRGBO(5, 222, 250, 1),
        Color.fromRGBO(134, 231, 214, 1),
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
              particleColor: Colors.white.withAlpha(150),
              awayAnimationDuration: const Duration(milliseconds: 600),
              maxParticleSize: 8,
              isRandSize: true,
              isRandomColor: true,
              randColorList: listParticleColor,
              awayAnimationCurve: Curves.easeInOutBack,
              enableHover: true,
              hoverColor: Colors.white,
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
                  if (orientation == Orientation.landscape) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.only(left: 30, right: 30),
                            child: PulseAnimation(
                              maxScale: 1.0,
                              minScale: 0.8,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .25,
                                  child: appLogoLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.only(left: 30, right: 30),
                            child: PulseAnimation(
                              maxScale: 1.0,
                              minScale: 0.8,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: appLogoLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
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
