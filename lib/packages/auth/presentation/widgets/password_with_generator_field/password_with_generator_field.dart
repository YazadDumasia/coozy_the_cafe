import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as faf;
import 'package:coozy_the_cafe/packages/auth/domain/services/password_generator.dart';
import 'package:coozy_the_cafe/packages/auth/domain/services/sign_up_validation_service.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/widgets/password_requirement_checklist/password_requirement_checklist.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

/// A comprehensive password field with a 1-tap "Generate Strong Password" feature
/// and a real-time requirement checklist that follows the SignUp page specifications.
class PasswordWithGeneratorField extends StatefulWidget {
  const PasswordWithGeneratorField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.onPasswordGenerated,
    this.showChecklist = true,
    this.showGeneratorButton = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onPasswordGenerated;
  final bool showChecklist;
  final bool showGeneratorButton;

  @override
  State<PasswordWithGeneratorField> createState() =>
      _PasswordWithGeneratorFieldState();
}

class _PasswordWithGeneratorFieldState
    extends State<PasswordWithGeneratorField> {
  final ValueNotifier<bool> _isObscureNotifier = ValueNotifier<bool>(true);
  final SignUpValidationService _validationService = SignUpValidationService();

  @override
  void dispose() {
    _isObscureNotifier.dispose();
    super.dispose();
  }

  void _generateStrongPassword() {
    final newPassword = PasswordGenerator.generate(length: 14);
    widget.controller.text = newPassword;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newPassword.length),
    );

    // Make visible temporarily so user can see it
    _isObscureNotifier.value = false;

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: newPassword));

    // Show subtle feedback
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr(
                  shared.LocaleKeys.resetPasswordGeneratedTooltip,
                  track: shared.TrackConstants.resetPasswordPageTrack,
                ) ??
                'Generated strong password & copied to clipboard!',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    widget.onChanged?.call(newPassword);
    widget.onPasswordGenerated?.call(newPassword);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLabel =
        widget.labelText ??
        (context.tr(
              shared.LocaleKeys.commonPasswordLabel,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Password');
    final effectiveHint =
        widget.hintText ??
        (context.tr(
              shared.LocaleKeys.commonPasswordHint,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Enter password');

    return ValueListenableBuilder<bool>(
      valueListenable: _isObscureNotifier,
      builder: (context, isObscure, _) {
        return ListenableBuilder(
          listenable: Listenable.merge([widget.controller, widget.focusNode]),
          builder: (context, _) {
            final text = widget.controller.text;
            final hasMin = _validationService.hasMinLength(text);
            final hasLower = _validationService.hasLowerCase(text);
            final hasUpper = _validationService.hasUpperCase(text);
            final hasNum = _validationService.hasNumeric(text);
            final hasSpec = _validationService.hasSpecialChar(text);
            final allMet =
                hasMin && hasLower && hasUpper && hasNum && hasSpec;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.showGeneratorButton) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      bottom: 6.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          effectiveLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: _generateStrongPassword,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary.withAlpha(80),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  context.tr(
                                    shared
                                        .LocaleKeys
                                        .resetPasswordGenerateBtn,
                                    track:
                                        shared
                                            .TrackConstants
                                            .resetPasswordPageTrack,
                                  ) ??
                                  'Generate Strong Password',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    keyboardType: TextInputType.text,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction:
                        widget.nextFocusNode != null
                            ? TextInputAction.next
                            : TextInputAction.done,
                    onFieldSubmitted: (value) {
                      if (widget.nextFocusNode != null) {
                        FocusScope.of(
                          context,
                        ).requestFocus(widget.nextFocusNode);
                      } else {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    validator:
                        widget.validator ??
                        (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr(
                                  shared
                                      .LocaleKeys
                                      .commonPasswordValidatorErrorEmptyMsg,
                                  track: shared.TrackConstants.commonTrack,
                                ) ??
                                'Please enter password';
                          }
                          if (!allMet) {
                            return context.tr(
                                  shared
                                      .LocaleKeys
                                      .commonPasswordValidatorErrorMsg,
                                  track: shared.TrackConstants.commonTrack,
                                ) ??
                                'Please satisfy all password requirements';
                          }
                          return null;
                        },
                    obscureText: isObscure,
                    autofillHints: const <String>[AutofillHints.newPassword],
                    onChanged: (value) {
                      widget.onChanged?.call(value);
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(18),
                      hintText: effectiveHint,
                      labelText:
                          widget.showGeneratorButton ? null : effectiveLabel,
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        tooltip: isObscure ? 'Show password' : 'Hide password',
                        onPressed: () {
                          _isObscureNotifier.value = !isObscure;
                        },
                        icon: faf.FaIcon(
                          isObscure
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
                ),
                if (widget.showChecklist) ...[
                  Visibility(
                    visible:
                        (widget.focusNode.hasFocus ||
                            widget.controller.text.isNotEmpty) &&
                        !allMet,
                    child: PasswordRequirementChecklist(
                      hasMinLength: hasMin,
                      hasLowerCase: hasLower,
                      hasUpperCase: hasUpper,
                      hasNumeric: hasNum,
                      hasSpecialChar: hasSpec,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
