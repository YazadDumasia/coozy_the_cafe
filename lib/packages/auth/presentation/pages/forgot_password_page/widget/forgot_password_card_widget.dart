import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/widgets/signpost_illustration_widget/signpost_illustration_widget.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../cubit/forgot_password_cubit.dart';
import '../forgot_password_page_actions.dart';

class ForgotPasswordCardWidget extends StatelessWidget {
  const ForgotPasswordCardWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.emailFocusNode,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final FocusNode emailFocusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
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
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Signpost Illustration
                const SignpostIllustrationWidget(width: 140, height: 110),
                const SizedBox(height: 20),

                // Title
                Text(
                  context.tr(
                        shared.LocaleKeys.forgotPasswordTitle,
                        track: shared.TrackConstants.forgotPasswordPageTrack,
                      ) ??
                      'Forgot your password?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  context.tr(
                        shared.LocaleKeys.forgotPasswordSubtitle,
                        track: shared.TrackConstants.forgotPasswordPageTrack,
                      ) ??
                      'Enter your email so that we can send you password reset link',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Email Label
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.forgotPasswordEmailLabel,
                          track: shared.TrackConstants.forgotPasswordPageTrack,
                        ) ??
                        'Email',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Email TextFormField
                TextFormField(
                  controller: emailController,
                  focusNode: emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onFieldSubmitted: (_) {
                    ForgotPasswordPageActions.onSendEmailPressed(
                      context: context,
                      formKey: formKey,
                      emailController: emailController,
                    );
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr(
                            shared.LocaleKeys.forgotPasswordEmailValidatorEmpty,
                            track:
                                shared.TrackConstants.forgotPasswordPageTrack,
                          ) ??
                          'Please enter your email.';
                    }
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return context.tr(
                            shared
                                .LocaleKeys
                                .forgotPasswordEmailValidatorInvalid,
                            track:
                                shared.TrackConstants.forgotPasswordPageTrack,
                          ) ??
                          'Please enter a valid email address.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    hintText:
                        context.tr(
                          shared.LocaleKeys.forgotPasswordEmailHint,
                          track: shared.TrackConstants.forgotPasswordPageTrack,
                        ) ??
                        'e.g. username@kinety.com',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    filled: true,
                    fillColor:
                        isDark
                            ? theme.colorScheme.surfaceContainerHighest
                                .withAlpha(80)
                            : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color:
                            isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color:
                            isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.colorScheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Send Email Button
                BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                  builder: (context, state) {
                    final isLoading = state is ForgotPasswordLoading;
                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () =>
                                    ForgotPasswordPageActions.onSendEmailPressed(
                                      context: context,
                                      formKey: formKey,
                                      emailController: emailController,
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
                                                .forgotPasswordSendingBtn,
                                            track:
                                                shared
                                                    .TrackConstants
                                                    .forgotPasswordPageTrack,
                                          ) ??
                                          'Sending...',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                                : Text(
                                  context.tr(
                                        shared.LocaleKeys.forgotPasswordSendBtn,
                                        track:
                                            shared
                                                .TrackConstants
                                                .forgotPasswordPageTrack,
                                      ) ??
                                      'Send Email',
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
                const SizedBox(height: 20),

                // < Back to Login Button
                Center(
                  child: TextButton.icon(
                    onPressed:
                        () => ForgotPasswordPageActions.onBackToLoginPressed(
                          context,
                        ),
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    label: Text(
                      context.tr(
                            shared.LocaleKeys.forgotPasswordBackToLogin,
                            track:
                                shared.TrackConstants.forgotPasswordPageTrack,
                          ) ??
                          'Back to Login',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade800,
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
