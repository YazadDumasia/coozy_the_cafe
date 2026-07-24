import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class StaffManagementActions {
  static void showSuccessDialog(BuildContext context, String message) {
    if (context.mounted) {
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonSuccess,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Success',
        descriptions: message,
        titleIcon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 50,
        ),
      );
    }
  }

  static void showErrorDialog(BuildContext context, String errorMessage) {
    if (context.mounted) {
      final defaultError =
          context.tr(
            shared.LocaleKeys.commonErrorMsg,
            track: shared.TrackConstants.commonTrack,
          ) ??
          'An error occurred.';
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonError,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Error',
        descriptions: errorMessage.isNotEmpty ? errorMessage : defaultError,
        titleIcon: const Icon(Icons.error, color: Colors.red, size: 50),
      );
    }
  }
}
