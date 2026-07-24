import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import 'widget/splash_screen_desktop_layout.dart';
import 'widget/splash_screen_mobile_layout.dart';
import 'widget/splash_screen_tablet_layout.dart';
import 'splash_page_actions.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final List<String> assetDirectories = <String>['images'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await SplashPageActions.checkFirstTime(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: const SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: shared.ResponsiveLayout(
            mobile: SplashScreenMobileLayout(),
            tablet: SplashScreenTabletLayout(),
            desktop: SplashScreenDesktopLayout(),
          ),
        ),
      ),
    );
  }
}
