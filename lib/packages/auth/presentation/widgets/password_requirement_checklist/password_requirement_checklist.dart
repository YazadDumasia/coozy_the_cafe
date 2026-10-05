import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

/// Reusable widget displaying real-time password strength requirements checklist,
/// matching the exact design and indicators of the SignUp page.
class PasswordRequirementChecklist extends StatelessWidget {
  const PasswordRequirementChecklist({
    super.key,
    required this.hasMinLength,
    required this.hasLowerCase,
    required this.hasUpperCase,
    required this.hasNumeric,
    required this.hasSpecialChar,
  });

  final bool hasMinLength;
  final bool hasLowerCase;
  final bool hasUpperCase;
  final bool hasNumeric;
  final bool hasSpecialChar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _RequirementRowItem(
            isMet: hasMinLength,
            label:
                context.tr(
                  shared.LocaleKeys.signUpPasswordSizeRequireText,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'Contains at least 8 characters',
          ),
          const SizedBox(height: 6),
          _RequirementRowItem(
            isMet: hasLowerCase,
            label:
                context.tr(
                  shared.LocaleKeys.signUpPasswordOneLowerCaseText,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'Contains at least 1 LowerCase character',
          ),
          const SizedBox(height: 6),
          _RequirementRowItem(
            isMet: hasUpperCase,
            label:
                context.tr(
                  shared.LocaleKeys.signUpPasswordOneUpperCaseText,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'Contains at least 1 Uppercase character',
          ),
          const SizedBox(height: 6),
          _RequirementRowItem(
            isMet: hasNumeric,
            label:
                context.tr(
                  shared.LocaleKeys.signUpPasswordOneNumCaseText,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'Contains at least 1 number',
          ),
          const SizedBox(height: 6),
          _RequirementRowItem(
            isMet: hasSpecialChar,
            label:
                context.tr(
                  shared.LocaleKeys.signUpPasswordOneSpecialCharText,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                r'Contains at least 1 special character like !@#$&*~+-',
          ),
        ],
      ),
    );
  }
}

class _RequirementRowItem extends StatelessWidget {
  const _RequirementRowItem({required this.isMet, required this.label});

  final bool isMet;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isMet ? Colors.green.shade600 : Colors.transparent,
            border: isMet
                ? Border.all(color: Colors.transparent)
                : Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isMet
                ? const Icon(Icons.check, color: Colors.white, size: 13)
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isMet
                  ? Colors.green.shade700
                  : theme.textTheme.bodySmall?.color?.withAlpha(180),
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
