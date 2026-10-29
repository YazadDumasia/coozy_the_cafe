import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class BusinessProfileActions {
  static Future<void> launchMapsUrl(BuildContext context, String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      try {
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            shared.SnackBarUtils.showWarning(
              context,
              message: 'Could not open URL: $trimmed',
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          shared.SnackBarUtils.showError(
            context,
            message: 'Error launching link: $e',
          );
        }
      }
    }
  }

  static Future<void> launchExternalUrl(BuildContext context, String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    var formattedUrl = trimmed;
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    final uri = Uri.tryParse(formattedUrl);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
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
}
