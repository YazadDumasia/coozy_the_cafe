import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as faf;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

/// Reusable Confirm Password Field following SignUp page standards
/// with visibility toggle and automatic match validation.
class ConfirmPasswordField extends StatefulWidget {
  const ConfirmPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.originalPasswordController,
    this.nextFocusNode,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextEditingController originalPasswordController;
  final FocusNode? nextFocusNode;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  final ValueNotifier<bool> _isObscureNotifier = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _isObscureNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLabel =
        widget.labelText ??
        (context.tr(
              shared.LocaleKeys.commonConfirmPasswordLabel,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Confirm Password');
    final effectiveHint =
        widget.hintText ??
        (context.tr(
              shared.LocaleKeys.commonConfirmPasswordHint,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Confirm your password');

    return ValueListenableBuilder<bool>(
      valueListenable: _isObscureNotifier,
      builder: (context, isObscure, _) {
        return Padding(
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
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
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
                              .resetPasswordConfirmPasswordMatchError,
                          track: shared.TrackConstants.resetPasswordPageTrack,
                        ) ??
                        'Please confirm your password';
                  }
                  if (value != widget.originalPasswordController.text) {
                    return context.tr(
                          shared
                              .LocaleKeys
                              .resetPasswordConfirmPasswordMatchError,
                          track: shared.TrackConstants.resetPasswordPageTrack,
                        ) ??
                        'Passwords do not match.';
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
              labelText: effectiveLabel,
              isDense: true,
              prefixIcon: Icon(
                Icons.lock_reset_rounded,
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
                borderSide: BorderSide(color: theme.colorScheme.primary),
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
                borderSide: BorderSide(color: theme.colorScheme.error),
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
    );
  }
}
