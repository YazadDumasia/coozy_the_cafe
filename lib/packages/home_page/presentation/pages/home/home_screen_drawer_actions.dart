import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart'
    as assets_gen;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class HomeScreenDrawerActions {
  static Future<PackageInfo> initPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  static void showComingSoon(BuildContext context, String message) {
    Navigator.pop(context);
    shared.DialogUtils.showAutoDismissDialog(
      context: context,
      title:
          context.tr(
            shared.LocaleKeys.commonInfo,
            track: shared.TrackConstants.commonTrack,
          ) ??
          'Info',
      descriptions:
          context.tr(
            shared.LocaleKeys.commonComingSoon,
            track: shared.TrackConstants.commonTrack,
          ) ??
          message,
      titleIcon: const Icon(Icons.info, color: Colors.blue, size: 50),
    );
  }

  static void onLicenseTap(BuildContext context) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      final String version = packageInfo.version;

      if (!context.mounted) return;

      showLicensePage(
        context: context,
        applicationName: "Coozy The Cafe",
        applicationIcon: CircleAvatar(
          radius: 52,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: AssetImage(
              assets_gen.Assets.images.appLogoClearBg.path,
            ),
          ),
        ),
        applicationLegalese: '© ${DateTime.now().year} Coozy The Cafe',
        applicationVersion: version,
        useRootNavigator: true,
      );
    });
  }
}
