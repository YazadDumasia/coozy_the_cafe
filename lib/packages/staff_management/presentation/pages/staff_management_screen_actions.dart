import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
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
        titleIcon: Lottie.asset(
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Assets.lottie.doneLightBrownColor
              : Assets.lottie.doneBrownColor,
          repeat: false,
        ),
      );
    }
  }

  static void showErrorDialog(BuildContext context, String errorMessage) {
    core.PlatformUtils.debugLog(
      StaffManagementActions,
      'showErrorDialog:onError: $errorMessage',
    );
    if (context.mounted) {
      final defaultError =
          context.tr(
            shared.LocaleKeys.commonErrorMsg,
            track: shared.TrackConstants.commonTrack,
          ) ??
          'Something when wrong. Please try again.';
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonError,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Error',
        descriptions: errorMessage.isNotEmpty ? errorMessage : defaultError,
        titleIcon: Lottie.asset(
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Assets.lottie.errorLightLoaderIcon
              : Assets.lottie.errorDarkLoaderIcon,
          repeat: false,
        ),
      );
    }
  }
}
