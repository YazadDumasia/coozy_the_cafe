import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart' as asts;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:synchronized/synchronized.dart';

class SplashPageActions {
  static Future<void> preloadImages(BuildContext context) async {
    final List<String> assetList = asts.Assets.images.values
        .map((asset) => asset.path)
        .toList();

    // Preload all assets from the list and handle errors
    final Lock lock = Lock();
    await Future.forEach(assetList, (asset) async {
      try {
        await lock.synchronized(() async {
          await precacheImage(AssetImage(asset), context);
        });
      } catch (e) {
        core.PlatformUtils.debugLog(
          SplashPageActions,
          'Error loading image:$asset',
        );
      }
    });
    core.PlatformUtils.debugLog(SplashPageActions, 'preloadImages:Done');
  }

  static Future<void> checkFirstTime(BuildContext context) async {
    final bool isUserLogin = shared.LocalManager.instance.isLoggedIn;
    await preloadImages(context);
    if (isUserLogin == false) {
      await Future.delayed(const Duration(seconds: 3)).then((value) async {
        final bool isloginFirstTime = shared.LocalManager.instance.getBoolValue(
          key: shared.PreferencesKeys.isAppLoginForFirstTime,
        );
        if (isloginFirstTime) {
          await shared.LocalManager.instance.setBoolValue(
            key: shared.PreferencesKeys.isAppLoginForFirstTime,
            value: false,
          );
        }
        if (context.mounted) {
          context.navigateToLogin(isFirstTime: isloginFirstTime);
        }
      });
    } else {
      await Future.delayed(const Duration(seconds: 3)).then((value) async {
        if (context.mounted) {
          context.navigateToHome();
        }
      });
    }
  }
}
