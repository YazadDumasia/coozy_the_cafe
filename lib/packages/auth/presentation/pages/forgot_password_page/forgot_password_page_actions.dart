import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'cubit/forgot_password_cubit.dart';

class ForgotPasswordPageActions {
  static void onBackToLoginPressed(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutePath.loginRoute);
    }
  }

  static void onSendEmailPressed({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<ForgotPasswordCubit>().sendResetEmail(emailController.text);
    }
  }

  static void onProceedToResetPassword({
    required BuildContext context,
    required String email,
    String? temporaryPassword,
  }) {
    final encodedEmail = Uri.encodeComponent(email);
    context.push(
      '${AppRoutePath.resetPasswordRoute}?email=$encodedEmail',
      extra: {
        'email': email,
        'token': temporaryPassword ?? '',
      },
    );
  }

  static void showSuccessSentDialog({
    required BuildContext context,
    required String email,
    String? otpCode,
    String? temporaryPassword,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(
            Icons.mark_email_read_rounded,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            context.tr(
                  shared.LocaleKeys.forgotPasswordTitle,
                  track: shared.TrackConstants.forgotPasswordPageTrack,
                ) ??
                'Forgot your password?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(
                      shared.LocaleKeys.forgotPasswordEmailSentMsg,
                      track: shared.TrackConstants.forgotPasswordPageTrack,
                    ) ??
                    'Password reset link sent to your email successfully.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You can proceed directly to set your new password.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),

              // ── DEBUG-only: show the temporary password ──────────────
              if (temporaryPassword != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.amber.shade700,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bug_report_rounded,
                            size: 14,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'DEBUG — Temp Password',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              temporaryPassword,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                color: Colors.amber.shade900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy password',
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: Colors.amber.shade800,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: temporaryPassword),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Temp password copied!'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              // ────────────────────────────────────────────────────────
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onBackToLoginPressed(context);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.tr(
                      shared.LocaleKeys.forgotPasswordBackToLogin,
                      track: shared.TrackConstants.forgotPasswordPageTrack,
                    ) ??
                    'Back to Login',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onProceedToResetPassword(
                  context: context,
                  email: email,
                  temporaryPassword: temporaryPassword,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.tr(
                      shared.LocaleKeys.forgotPasswordResetPasswordNow,
                      track: shared.TrackConstants.forgotPasswordPageTrack,
                    ) ??
                    'Reset Password Now',
              ),
            ),
          ],
        );
      },
    );
  }
}

