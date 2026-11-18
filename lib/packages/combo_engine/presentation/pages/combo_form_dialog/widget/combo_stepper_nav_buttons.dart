import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class ComboStepperNavButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const ComboStepperNavButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps - 1;
    final isMobile = shared.ResponsiveLayout.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant
                .withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (currentStep > 0)
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                context.tr(
                      shared.LocaleKeys.comboFormDialogBackBtn,
                      track: shared.TrackConstants.comboPageTrack,
                    ) ??
                    'Back',
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14 : 20,
                  vertical: isMobile ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          // Next or Save button
          if (!isLastStep)
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                context.tr(
                      shared.LocaleKeys.comboFormDialogNextBtn,
                      track: shared.TrackConstants.comboPageTrack,
                    ) ??
                    'Next',
              ),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 24,
                  vertical: isMobile ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          else
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                context.tr(
                      isMobile
                          ? shared.LocaleKeys.comboFormDialogSaveBtn
                          : shared.LocaleKeys.comboFormDialogSaveComboBtn,
                      track: shared.TrackConstants.comboPageTrack,
                    ) ??
                    (isMobile ? 'Save' : 'Save Combo'),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 24,
                  vertical: isMobile ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
