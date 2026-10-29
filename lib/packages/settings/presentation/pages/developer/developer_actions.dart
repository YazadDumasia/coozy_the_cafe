import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart'
    as assets_gen;

class DeveloperActions {
  static Future<void> openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            shared.SnackBarUtils.showWarning(
              context,
              message: 'Could not open URL: $url',
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          shared.SnackBarUtils.showError(
            context,
            message: 'Error opening webpage: $e',
          );
        }
      }
    }
  }

  static void showAppLicenses(BuildContext context) {
    PackageInfo.fromPlatform().then((packageInfo) {
      if (!context.mounted) return;
      showLicensePage(
        context: context,
        applicationName: 'Coozy The Cafe',
        applicationIcon: CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(
              assets_gen.Assets.images.appLogoClearBg.path,
            ),
          ),
        ),
        applicationLegalese: '© ${DateTime.now().year} Coozy The Cafe. Open-Source under MIT License.',
        applicationVersion: packageInfo.version,
        useRootNavigator: true,
      );
    });
  }
}
