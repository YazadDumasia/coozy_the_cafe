import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as faf;
import 'package:coozy_the_cafe/packages/auth/presentation/widgets/confirm_password_field/confirm_password_field.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/widgets/password_with_generator_field/password_with_generator_field.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../change_password_page_actions.dart';
import '../cubit/change_password_cubit.dart';

class ChangePasswordCardWidget extends StatefulWidget {
  const ChangePasswordCardWidget({
    super.key,
    required this.formKey,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.currentPasswordFocusNode,
    required this.newPasswordFocusNode,
    required this.confirmPasswordFocusNode,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final FocusNode currentPasswordFocusNode;
  final FocusNode newPasswordFocusNode;
  final FocusNode confirmPasswordFocusNode;

  @override
  State<ChangePasswordCardWidget> createState() =>
      _ChangePasswordCardWidgetState();
}

class _ChangePasswordCardWidgetState extends State<ChangePasswordCardWidget> {
  final ValueNotifier<bool> _isCurrentObscureNotifier = ValueNotifier<bool>(
    true,
  );

  @override
  void dispose() {
    _isCurrentObscureNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 34),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withAlpha(90)
                        : Colors.black.withAlpha(18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: widget.formKey,
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
                      Icons.shield_outlined,
                      size: 38,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  context.tr(
                        shared.LocaleKeys.changePasswordTitle,
                        track: shared.TrackConstants.changePasswordPageTrack,
                      ) ??
                      'Change Password',
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
                        shared.LocaleKeys.changePasswordSubtitle,
                        track: shared.TrackConstants.changePasswordPageTrack,
                      ) ??
                      'Update your password regularly to keep your cafe account secure.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Current Password Field
                ValueListenableBuilder<bool>(
                  valueListenable: _isCurrentObscureNotifier,
                  builder: (context, isCurrentObscure, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        controller: widget.currentPasswordController,
                        focusNode: widget.currentPasswordFocusNode,
                        obscureText: isCurrentObscure,
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(widget.newPasswordFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr(
                                  shared
                                      .LocaleKeys
                                      .changePasswordCurrentPasswordEmptyError,
                                  track:
                                      shared
                                          .TrackConstants
                                          .changePasswordPageTrack,
                                ) ??
                                'Please enter your current password.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(18),
                          labelText:
                              context.tr(
                                shared
                                    .LocaleKeys
                                    .changePasswordCurrentPasswordLabel,
                                track:
                                    shared
                                        .TrackConstants
                                        .changePasswordPageTrack,
                              ) ??
                              'Current Password',
                          hintText:
                              context.tr(
                                shared
                                    .LocaleKeys
                                    .changePasswordCurrentPasswordHint,
                                track:
                                    shared
                                        .TrackConstants
                                        .changePasswordPageTrack,
                              ) ??
                              'Enter current password',
                          isDense: true,
                          prefixIcon: Icon(
                            Icons.key_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          suffixIcon: IconButton(
                            tooltip:
                                isCurrentObscure
                                    ? 'Show password'
                                    : 'Hide password',
                            onPressed: () {
                              _isCurrentObscureNotifier.value =
                                  !isCurrentObscure;
                            },
                            icon: faf.FaIcon(
                              isCurrentObscure
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
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),

                // New Password Field with 1-Tap Generator & Checklist
                PasswordWithGeneratorField(
                  controller: widget.newPasswordController,
                  focusNode: widget.newPasswordFocusNode,
                  nextFocusNode: widget.confirmPasswordFocusNode,
                  labelText:
                      context.tr(
                        shared.LocaleKeys.changePasswordNewPasswordLabel,
                        track: shared.TrackConstants.changePasswordPageTrack,
                      ) ??
                      'New Password',
                  hintText:
                      context.tr(
                        shared.LocaleKeys.changePasswordNewPasswordHint,
                        track: shared.TrackConstants.changePasswordPageTrack,
                      ) ??
                      'Enter new password',
                  showGeneratorButton: true,
                  showChecklist: true,
                  onPasswordGenerated: (generatedPassword) {
                    widget.confirmPasswordController.text = generatedPassword;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm New Password Field
                ConfirmPasswordField(
                  controller: widget.confirmPasswordController,
                  focusNode: widget.confirmPasswordFocusNode,
                  originalPasswordController: widget.newPasswordController,
                  labelText:
                      context.tr(
                        shared.LocaleKeys.changePasswordConfirmNewPasswordLabel,
                        track: shared.TrackConstants.changePasswordPageTrack,
                      ) ??
                      'Confirm New Password',
                  hintText:
                      context.tr(
                        shared.LocaleKeys.changePasswordConfirmNewPasswordHint,
                        track: shared.TrackConstants.changePasswordPageTrack,
                      ) ??
                      'Re-enter your new password',
                ),
                const SizedBox(height: 28),

                // Update Password Button
                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  builder: (context, state) {
                    final isLoading = state is ChangePasswordLoading;
                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () =>
                                    ChangePasswordPageActions.onSubmitChangePressed(
                                      context: context,
                                      formKey: widget.formKey,
                                      currentPasswordController:
                                          widget.currentPasswordController,
                                      newPasswordController:
                                          widget.newPasswordController,
                                      confirmPasswordController:
                                          widget.confirmPasswordController,
                                    ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFF5C28), // Orange pill accent
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:
                            isLoading
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      context.tr(
                                            shared
                                                .LocaleKeys
                                                .changePasswordUpdatingBtn,
                                            track:
                                                shared
                                                    .TrackConstants
                                                    .changePasswordPageTrack,
                                          ) ??
                                          'Updating...',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                                : Text(
                                  context.tr(
                                        shared.LocaleKeys.changePasswordBtn,
                                        track:
                                            shared
                                                .TrackConstants
                                                .changePasswordPageTrack,
                                      ) ??
                                      'Update Password',
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
                const SizedBox(height: 14),

                // Cancel Button
                Center(
                  child: TextButton(
                    onPressed:
                        () => ChangePasswordPageActions.onBackPressed(context),
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.changePasswordBackBtn,
                            track: shared.TrackConstants.changePasswordPageTrack,
                          ) ??
                          'Cancel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
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
