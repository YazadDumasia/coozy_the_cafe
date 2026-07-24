import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    super.key,
  });
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 550;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 550 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return mobile ?? Container();
        } else if (constraints.maxWidth < 1200) {
          return tablet ?? Container();
        } else {
          return desktop ?? Container();
        }
      },
    );
  }
}

/*
ResponsiveLayout(
  mobile: Text(context.tr(LocaleKeys.autoMobileLayout) ?? 'Mobile layout'),
  tablet: Text(context.tr(LocaleKeys.autoTabletLayout) ?? 'Tablet layout'),
  desktop: Text(context.tr(LocaleKeys.autoDesktopLayout) ?? 'Desktop layout'),
)
 */
