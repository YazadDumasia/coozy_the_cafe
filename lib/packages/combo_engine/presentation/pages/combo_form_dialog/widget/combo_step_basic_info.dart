import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class ComboStepBasicInfo extends StatelessWidget {
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final TextEditingController descriptionController;
  final FocusNode descriptionFocusNode;
  final ValueNotifier<bool> isActiveNotifier;

  const ComboStepBasicInfo({
    super.key,
    required this.nameController,
    required this.nameFocusNode,
    required this.descriptionController,
    required this.descriptionFocusNode,
    required this.isActiveNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                              shared
                                  .LocaleKeys
                                  .comboFormDialogStepBasicInfoTitle,
                              track: shared.TrackConstants.comboPageTrack,
                            ) ??
                            'Basic Info',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(
                              shared
                                  .LocaleKeys
                                  .comboFormDialogStepBasicInfoSubtitle,
                              track: shared.TrackConstants.comboPageTrack,
                            ) ??
                            'Provide a catchy name and optional description for your bundle offer.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Combo Name Field
          Text(
            context.tr(
                  shared.LocaleKeys.comboFormDialogNameLabel,
                  track: shared.TrackConstants.comboPageTrack,
                ) ??
                'Combo / Bundle Name *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            focusNode: nameFocusNode,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText:
                  context.tr(
                    shared.LocaleKeys.comboFormDialogNameHint,
                    track: shared.TrackConstants.comboPageTrack,
                  ) ??
                  'e.g. Breakfast Duo, Coffee + Pastry',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.fastfood_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return context.tr(
                      shared.LocaleKeys.comboFormDialogNameRequired,
                      track: shared.TrackConstants.comboPageTrack,
                    ) ??
                    'Combo name is required';
              }
              if (v.trim().length < 2) {
                return context.tr(
                      shared.LocaleKeys.comboFormDialogNameMinLength,
                      track: shared.TrackConstants.comboPageTrack,
                    ) ??
                    'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Description Field
          Text(
            context.tr(
                  shared.LocaleKeys.comboFormDialogDescLabel,
                  track: shared.TrackConstants.comboPageTrack,
                ) ??
                'Description (Optional)',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: descriptionController,
            focusNode: descriptionFocusNode,
            maxLines: 3,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText:
                  context.tr(
                    shared.LocaleKeys.comboFormDialogDescHint,
                    track: shared.TrackConstants.comboPageTrack,
                  ) ??
                  'Briefly describe this combo offer and what makes it special...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.description_outlined),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // Active switch container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                              shared.LocaleKeys.comboFormDialogActiveLabel,
                              track: shared.TrackConstants.comboPageTrack,
                            ) ??
                            'Active for Ordering',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(
                              shared.LocaleKeys.comboFormDialogActiveDesc,
                              track: shared.TrackConstants.comboPageTrack,
                            ) ??
                            'When active, customers and staff can select this combo in the POS/Menu.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: isActiveNotifier,
                  builder: (context, isActive, _) {
                    return Switch.adaptive(
                      value: isActive,
                      onChanged: (val) {
                        isActiveNotifier.value = val;
                      },
                      activeThumbColor: colorScheme.primary,
                      activeTrackColor: colorScheme.primary.withValues(
                        alpha: 0.38,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
