import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class OtpVerificationPageActions {
  static void handleBackPress(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutePath.loginRoute);
    }
  }

  static Future<void> handleVerify({
    required BuildContext context,
    required String currentText,
    required String? expectedOtpNumber,
    TextEditingController? pinController,
    bool? isForgetPassword,
    String? email,
  }) async {
    if (currentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 4-digit verification code.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (currentText == expectedOtpNumber) {
      core.PlatformUtils.debugLog(
        OtpVerificationPageActions,
        'OTP verified successfully.',
      );
      await shared.LocalManager.instance.setBoolValue(
        key: shared.PreferencesKeys.isLoggedIn,
        value: true,
      );

      if (context.mounted) {
        if (isForgetPassword == true) {
          final encodedEmail = Uri.encodeComponent(email ?? '');
          context.go(
            '${AppRoutePath.resetPasswordRoute}?email=$encodedEmail',
            extra: {'email': email ?? ''},
          );
        } else {
          context.go(
            AppRoutePath.successfullyScreenRoute,
            extra: {'redirectPath': AppRoutePath.homeRoute},
          );
        }
      }
    } else {
      core.PlatformUtils.debugLog(
        OtpVerificationPageActions,
        'OTP verification failed. Entered: $currentText, Expected: $expectedOtpNumber',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Incorrect verification code. Please check and try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static String generateNewOtp() {
    return (math.Random().nextInt(9000) + 1000).toString();
  }

  static Future<void> sendOtpMessage({
    required BuildContext context,
    required String? phoneNumber,
    required String? appSignature,
    required String newOtpNumber,
  }) async {
    if (core.PlatformUtils.isMobileApp() == true) {
      final String smsMessage =
          '<#> Your code is $newOtpNumber\t Code:${appSignature ?? ""}';
      core.PlatformUtils.debugLog(OtpVerificationPageActions, smsMessage);
      core.PlatformUtils.debugLog(
        OtpVerificationPageActions,
        'OTP Sent successfully',
      );
    } else {
      final String smsMessage = 'Your code is $newOtpNumber.';
      core.PlatformUtils.debugLog(OtpVerificationPageActions, smsMessage);
      core.PlatformUtils.debugLog(
        OtpVerificationPageActions,
        'OTP Code: $newOtpNumber sent successfully',
      );

      if (context.mounted) {
        shared.DialogUtils.showAutoDismissDialog(
          showDuration: const Duration(seconds: 4),
          context: context,
          title:
              context.tr(
                shared.LocaleKeys.commonInfo,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Info',
          descriptions:
              context.tr(
                shared.LocaleKeys.webOtpMsg,
                params: {'otpCode': newOtpNumber},
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Web OTP: $newOtpNumber',
          titleIcon: const Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 48,
          ),
        );
      }
    }
  }

  static String loadSmsSendParams(String? phoneNumber, String? messageBody) {
    final Map<String, dynamic> map = <String, dynamic>{
      'PhoneTo': phoneNumber.toString(),
      'smsMessage': messageBody.toString(),
    };
    return json.encode(map);
  }
}
