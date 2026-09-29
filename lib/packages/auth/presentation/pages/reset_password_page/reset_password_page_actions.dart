import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'cubit/reset_password_cubit.dart';

class ResetPasswordPageActions {
  static void onBackToLoginPressed(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutePath.loginRoute);
    }
  }

  static void onSubmitResetPressed({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String email,
    required TextEditingController mailPasswordController,
    required TextEditingController newPasswordController,
    required TextEditingController confirmPasswordController,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<ResetPasswordCubit>().submitResetPassword(
        email: email,
        mailPassword: mailPasswordController.text,
        newPassword: newPasswordController.text,
      );
    }
  }

  static void showSuccessResetDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(
            Icons.check_circle_outline_rounded,
            size: 60,
            color: Colors.green.shade600,
          ),
          title: Text(
            context.tr(
                  shared.LocaleKeys.resetPasswordSuccessMsg,
                  track: shared.TrackConstants.resetPasswordPageTrack,
                ) ??
                'Password Reset Successfully!',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your password has been changed. You can now login using your new password.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(AppRoutePath.loginRoute);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
              child: const Text('Proceed to Login'),
            ),
          ],
        );
      },
    );
  }
}
