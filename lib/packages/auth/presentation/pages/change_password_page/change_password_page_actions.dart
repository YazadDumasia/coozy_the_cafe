import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'cubit/change_password_cubit.dart';

class ChangePasswordPageActions {
  static void onBackPressed(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutePath.settingsScreenRoute);
    }
  }

  static void onSubmitChangePressed({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController currentPasswordController,
    required TextEditingController newPasswordController,
    required TextEditingController confirmPasswordController,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      if (currentPasswordController.text == newPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                    shared.LocaleKeys.changePasswordNewPasswordSameError,
                    track: shared.TrackConstants.changePasswordPageTrack,
                  ) ??
                  'New password cannot be the same as current password.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      FocusScope.of(context).unfocus();
      context.read<ChangePasswordCubit>().submitChangePassword(
        oldPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
    }
  }

  static void showSuccessChangeDialog(BuildContext context) {
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
            Icons.verified_user_rounded,
            size: 56,
            color: Colors.green.shade600,
          ),
          title: Text(
            context.tr(
                  shared.LocaleKeys.changePasswordTitle,
                  track: shared.TrackConstants.changePasswordPageTrack,
                ) ??
                'Password Changed',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            context.tr(
                  shared.LocaleKeys.changePasswordSuccessMsg,
                  track: shared.TrackConstants.changePasswordPageTrack,
                ) ??
                'Your password has been updated successfully!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onBackPressed(context);
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
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
