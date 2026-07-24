import 'package:device_info_plus/device_info_plus.dart' as device_info;
import 'package:package_info_plus/package_info_plus.dart' as pack_info;
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../../core/coozy_core.dart' as core;
import '../../coozy_shared.dart' as shared;

class LaunchReview {
  // Launch method with dynamic iOS App ID and optional custom error message
  Future<void> launch({
    required String iOSAppId,
    bool writeReview = false,
    String? customErrorMessage,
  }) async {
    // Fetch app package info
    final pack_info.PackageInfo packageInfo =
        await pack_info.PackageInfo.fromPlatform();
    final String appId =
        packageInfo.packageName; // This is the app ID for Android

    // Android URIs
    final Uri androidUri = Uri.parse('market://details?id=$appId');
    final Uri androidWebUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$appId',
    );

    // iOS URIs
    final String appStoreLink = 'https://apps.apple.com/app/id$iOSAppId';
    final Uri iOSUri = Uri.parse(
      writeReview ? '$appStoreLink?action=write-review' : appStoreLink,
    );
    final Uri testFlightUri = Uri.parse(
      'itms-beta://beta.itunes.apple.com/v1/app/id$iOSAppId',
    );

    try {
      if (core.PlatformUtils.isIOS()) {
        // Check if the app is running in TestFlight
        final bool isTestFlight = await _isRunningInTestFlight();

        if (isTestFlight) {
          // Launch TestFlight URL if available
          if (await url_launcher.canLaunchUrl(testFlightUri)) {
            await url_launcher.launchUrl(testFlightUri);
          } else if (await url_launcher.canLaunchUrl(iOSUri)) {
            await url_launcher.launchUrl(iOSUri);
          } else {
            throw 'Could not launch App Store or TestFlight';
          }
        } else {
          // Launch regular App Store URL
          if (await url_launcher.canLaunchUrl(iOSUri)) {
            await url_launcher.launchUrl(iOSUri);
          } else {
            throw 'Could not launch App Store';
          }
        }
      } else if (core.PlatformUtils.isAndroid()) {
        // Try to open the Play Store app first
        if (await url_launcher.canLaunchUrl(androidUri)) {
          await url_launcher.launchUrl(androidUri);
        } else {
          // Fallback to Play Store link in browser if Play Store app is unavailable
          await url_launcher.launchUrl(androidWebUri);
        }
      } else {
        // Log for unsupported platforms
        final String plf = await core.PlatformUtils.getCurrentPlatform();
        core.PlatformUtils.debugLog(
          LaunchReview,
          'Other Platform review opening: $plf',
        );
      }
    } catch (e) {
      // Show user-friendly message if an error occurs
      final String message =
          customErrorMessage ??
          'Failed to launch the review page. Please try again.';
      shared.Constants.showToastMsg(msg: message);
      core.PlatformUtils.debugLog(
        LaunchReview,
        'Error launching review page: $e',
      );
    }
  }

  // Method to check if the app is running in TestFlight
  Future<bool> _isRunningInTestFlight() async {
    final device_info.DeviceInfoPlugin deviceInfoPlugin =
        device_info.DeviceInfoPlugin();
    final device_info.IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;

    // TestFlight detection using iOS version or custom logic
    return iosInfo.systemName == 'iOS' &&
        iosInfo.systemVersion.contains('TestFlight');
  }
}

/*
 LaunchReview().launch(
  writeReview: true,
  iOSAppId: '1234567890',
  customErrorMessage: 'Oops! Something went wrong while opening the review page.'
);

or

LaunchReview().launch(
  writeReview: true,
  iOSAppId: '1234567890'
);

*/
