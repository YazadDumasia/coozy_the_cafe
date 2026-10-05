import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class OtpVerificationCardWidget extends StatelessWidget {
  const OtpVerificationCardWidget({
    super.key,
    required this.formKey,
    required this.pinController,
    required this.pinFocusNode,
    required this.phoneNumber,
    required this.currentOtpNumber,
    required this.countdownAnimation,
    required this.onChanged,
    required this.onVerify,
    required this.onResend,
    required this.onAutoFillDemo,
    required this.onBack,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController pinController;
  final FocusNode pinFocusNode;
  final String? phoneNumber;
  final String? currentOtpNumber;
  final Animation<int> countdownAnimation;
  final ValueChanged<String> onChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onAutoFillDemo;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(90)
                    : Colors.black.withAlpha(20),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Back Button Row
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                                  .withAlpha(120)
                            : Colors.grey.shade100,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Top Email Illustration Badge
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A65), Color(0xFFFF5722)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5722).withAlpha(80),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                context.tr(
                      shared
                          .LocaleKeys
                          .otpVerificationPageVerificationCodeTitle,
                      track: shared.TrackConstants.otpVerificationPageTrack,
                    ) ??
                    'Verification Code',
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
                      shared
                          .LocaleKeys
                          .otpVerificationPageVerificationCodeSubtitle,
                      track: shared.TrackConstants.otpVerificationPageTrack,
                      params: {'phoneNumber': phoneNumber ?? ''},
                    ) ??
                    'Please enter verification code sent to your mobile number ${phoneNumber ?? ""}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              // Demo Helper Chip
              if (currentOtpNumber != null && currentOtpNumber!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onAutoFillDemo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5C28)
                              .withAlpha(isDark ? 35 : 18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFF5C28).withAlpha(70),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.key_rounded,
                              size: 15,
                              color: Color(0xFFFF5C28),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Demo Code: $currentOtpNumber',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF5C28),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(Tap to fill)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // PIN Code Form Fields using sms_autofill PinFieldAutoFill
              Center(
                child: SizedBox(
                  width: 290,
                  height: 56,
                  child: Form(
                    key: formKey,
                    child: PinFieldAutoFill(
                      controller: pinController,
                      focusNode: pinFocusNode,
                      codeLength: 4,
                      autoFocus: true,
                      // currentCode: currentOtpNumber,
                      decoration: BoxLooseDecoration(
                        radius: const Radius.circular(14),
                        strokeWidth: 1.5,
                        gapSpace: 12,
                        strokeColorBuilder: PinListenColorBuilder(
                          theme.colorScheme.primary,
                          isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                        bgColorBuilder: FixedColorBuilder(
                          isDark
                              ? theme.colorScheme.surfaceContainerHighest
                                    .withAlpha(80)
                              : Colors.grey.shade50,
                        ),
                        textStyle: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                        signed: false,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onCodeChanged: (val) {
                        final text = val ?? '';
                        onChanged(text);
                      },
                      onCodeSubmitted: (val) {
                        onChanged(val);
                        onVerify();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Verify Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5C28),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: const Color(0xFFFF5C28).withAlpha(90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.otpVerificationPageVerifyBtn,
                          track: shared.TrackConstants.otpVerificationPageTrack,
                        ) ??
                        'Verify',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Grouped Resend Section
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      context.tr(
                            shared
                                .LocaleKeys
                                .otpVerificationPageDidntReceiveCode,
                            track:
                                shared.TrackConstants.otpVerificationPageTrack,
                          ) ??
                          "Didn't receive code?",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    shared.CountDownTimer(
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      animation: countdownAnimation,
                      onPressed: onResend,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
