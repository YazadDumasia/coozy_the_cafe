import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as faf;
import 'package:coozy_the_cafe/packages/auth/presentation/widgets/confirm_password_field/confirm_password_field.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/widgets/password_with_generator_field/password_with_generator_field.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../cubit/reset_password_cubit.dart';
import '../reset_password_page_actions.dart';

class ResetPasswordCardWidget extends StatelessWidget {
  const ResetPasswordCardWidget({
    super.key,
    required this.formKey,
    required this.email,
    required this.mailPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.mailPasswordFocusNode,
    required this.newPasswordFocusNode,
    required this.confirmPasswordFocusNode,
  });

  final GlobalKey<FormState> formKey;
  final String email;
  final TextEditingController mailPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final FocusNode mailPasswordFocusNode;
  final FocusNode newPasswordFocusNode;
  final FocusNode confirmPasswordFocusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ValueNotifier<bool> isMailPasswordObscured = ValueNotifier<bool>(
      true,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 34),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(90)
                    : Colors.black.withAlpha(18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Security Key Badge Icon
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withAlpha(70),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 38,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  context.tr(
                        shared.LocaleKeys.resetPasswordTitle,
                        track: shared.TrackConstants.resetPasswordPageTrack,
                      ) ??
                      'Reset Password',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  context.tr(
                        shared.LocaleKeys.resetPasswordSubtitle,
                        track: shared.TrackConstants.resetPasswordPageTrack,
                      ) ??
                      'Enter your new password below. Make sure it\'s strong and secure.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),

                // 1. Password Provided via Mail Field
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    bottom: 6.0,
                  ),
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.resetPasswordMailPasswordLabel,
                          track: shared.TrackConstants.resetPasswordPageTrack,
                        ) ??
                        'Password Provided via Mail',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isMailPasswordObscured,
                    builder: (context, obscured, _) {
                      return TextFormField(
                        controller: mailPasswordController,
                        focusNode: mailPasswordFocusNode,
                        obscureText: obscured,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          newPasswordFocusNode.requestFocus();
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(18),
                          isDense: true,
                          hintText:
                              context.tr(
                                shared.LocaleKeys.resetPasswordMailPasswordHint,
                                track: shared
                                    .TrackConstants
                                    .resetPasswordPageTrack,
                              ) ??
                              'Enter Mail Password',
                          prefixIcon: Icon(
                            Icons.mail_lock_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          suffixIcon: IconButton(
                            tooltip: obscured
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () {
                              isMailPasswordObscured.value = !obscured;
                            },
                            icon: faf.FaIcon(
                              obscured
                                  ? faf.FontAwesomeIcons.eye
                                  : faf.FontAwesomeIcons.eyeSlash,
                              size: 18,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary.withAlpha(120),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.error,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.error,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr(
                                  shared
                                      .LocaleKeys
                                      .resetPasswordMailPasswordRequired,
                                  track: shared
                                      .TrackConstants
                                      .resetPasswordPageTrack,
                                ) ??
                                'Please enter the password provided via email.';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // 2. New Password Field with Random Generator & SignUp Requirement Checklist
                PasswordWithGeneratorField(
                  controller: newPasswordController,
                  focusNode: newPasswordFocusNode,
                  nextFocusNode: confirmPasswordFocusNode,
                  labelText:
                      context.tr(
                        shared.LocaleKeys.resetPasswordNewPasswordLabel,
                        track: shared.TrackConstants.resetPasswordPageTrack,
                      ) ??
                      'New Password',
                  hintText:
                      context.tr(
                        shared.LocaleKeys.resetPasswordNewPasswordHint,
                        track: shared.TrackConstants.resetPasswordPageTrack,
                      ) ??
                      'Enter New Password',
                  showGeneratorButton: true,
                  showChecklist: true,
                  onPasswordGenerated: (generatedPassword) {
                    confirmPasswordController.text = generatedPassword;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Confirm New Password Field
                ConfirmPasswordField(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocusNode,
                  originalPasswordController: newPasswordController,
                  labelText:
                      context.tr(
                        shared.LocaleKeys.resetPasswordConfirmPasswordLabel,
                        track: shared.TrackConstants.resetPasswordPageTrack,
                      ) ??
                      'Confirm New Password',
                  hintText:
                      context.tr(
                        shared.LocaleKeys.resetPasswordConfirmPasswordHint,
                        track: shared.TrackConstants.resetPasswordPageTrack,
                      ) ??
                      'Confirm New Password',
                ),
                const SizedBox(height: 28),

                // Submit Reset Password Button
                BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                  builder: (context, state) {
                    final isLoading = state is ResetPasswordLoading;
                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () =>
                                  ResetPasswordPageActions.onSubmitResetPressed(
                                    context: context,
                                    formKey: formKey,
                                    email: email,
                                    mailPasswordController:
                                        mailPasswordController,
                                    newPasswordController:
                                        newPasswordController,
                                    confirmPasswordController:
                                        confirmPasswordController,
                                  ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFF5C28,
                          ), // Orange pill accent
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    context.tr(
                                          shared
                                              .LocaleKeys
                                              .resetPasswordResettingBtn,
                                          track: shared
                                              .TrackConstants
                                              .resetPasswordPageTrack,
                                        ) ??
                                        'Resetting...',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                context.tr(
                                      shared.LocaleKeys.resetPasswordBtn,
                                      track: shared
                                          .TrackConstants
                                          .resetPasswordPageTrack,
                                    ) ??
                                    'Reset Password',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),

                // < Back to Login Button
                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        ResetPasswordPageActions.onBackToLoginPressed(context),
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    label: Text(
                      context.tr(
                            shared.LocaleKeys.resetPasswordBackToLogin,
                            track: shared.TrackConstants.resetPasswordPageTrack,
                          ) ??
                          'Back to Login',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
