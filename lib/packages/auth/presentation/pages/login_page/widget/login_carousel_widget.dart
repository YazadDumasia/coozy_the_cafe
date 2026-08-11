import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class LoginCarouselWidget extends StatelessWidget {
  const LoginCarouselWidget({
    super.key,
    required this.size,
    required this.images,
    required this.appLogoLight,
  });

  final Size size;
  final List<String> images;
  final Widget appLogoLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      padding: EdgeInsets.all(20.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: AbsorbPointer(
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                autoPlayCurve: Curves.fastOutSlowIn,
                aspectRatio: 16 / 9,
                pauseAutoPlayOnTouch: true,
                initialPage: 0,
                pauseAutoPlayInFiniteScroll: false,
                autoPlayAnimationDuration: const Duration(seconds: 1),
                viewportFraction: 1.0,
                height: size.height,
              ),
              items: images.asMap().entries.map((entry) {
                final int index = entry.key;
                final String image = entry.value;

                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Stack(
                        children: [
                          Container(
                            width: size.width,
                            height: size.height,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Image.asset(image, fit: BoxFit.fill),
                          ),
                          if (index == 0)
                            PositionedDirectional(
                              top: MediaQuery.of(context).size.height * 0.45,
                              start: 50.0,
                              end: 50.0,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10.0,
                                      sigmaY: 10.0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      child: IntrinsicWidth(
                                        child: IntrinsicHeight(
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(20.0),
                                              child: Column(
                                                children: [
                                                  appLogoLight,
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment: AlignmentGeometry
                                                        .center,
                                                    child: Text(
                                                      "Coozy The Cafe",
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .secondary,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
