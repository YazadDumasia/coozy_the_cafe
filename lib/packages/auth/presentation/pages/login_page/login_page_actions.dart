import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:flutter/services.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as share;
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/cubit/login_screen_cubit.dart';

class LoginPageActions {
  static Future<void> handlePopAction(
    BuildContext context,
    bool didPop,
    bool isCurrent,
  ) async {
    if (didPop) return;
    if (!isCurrent) return;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.tr(
                share.LocaleKeys.commonExit,
                track: share.TrackConstants.commonTrack,
              ) ??
              'Exit',
        ),
        content: Text(
          context.tr(
                share.LocaleKeys.commonDoYouWantToGoBack,
                track: share.TrackConstants.commonTrack,
              ) ??
              'Do you want to go back?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.tr(
                    share.LocaleKeys.commonNo,
                    track: share.TrackConstants.commonTrack,
                  ) ??
                  'No',
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.tr(
                    share.LocaleKeys.commonYes,
                    track: share.TrackConstants.commonTrack,
                  ) ??
                  'Yes',
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  static Future<void> callLoginApi(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController? emailTextEditingController,
    TextEditingController? passwordTextEditingController,
  ) async {
    if (formKey.currentState?.validate() ?? false) {
      final email = emailTextEditingController?.text ?? '';
      final password = passwordTextEditingController?.text ?? '';
      await context.read<LoginScreenCubit>().submitLogin(
        email: email,
        password: password,
        onSuccess: () {
          if (context.mounted) {
            context.navigateToHome();
          }
        },
        onError: (error) {
          if (context.mounted) {
            share.DialogUtils.showAutoDismissDialog(
              context: context,
              title: context.tr(
                share.LocaleKeys.commonError,
                track: share.TrackConstants.commonTrack,
              ) ?? 'Error',
              descriptions: error.isNotEmpty
                  ? error
                  : (context.tr(
                      share.LocaleKeys.commonErrorMsg,
                      track: share.TrackConstants.commonTrack,
                    ) ?? 'An error occurred.'),
              titleIcon: const Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ),
            );
          }
        },
      );
    }
  }

  static void onGoToRegisterPage(BuildContext context) {
    context.go(core.AppRoutePath.registrationRoute);
  }
}
