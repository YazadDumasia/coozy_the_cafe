import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../shared/widgets/animated_hint_textfield/animated_hint_textfield.dart';

class StaffSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final List<String>? hintTexts;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const StaffSearchBar({
    super.key,
    required this.controller,
    this.hintTexts,
    this.hintText = 'Search...',
    this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHintTexts = (hintTexts != null && hintTexts!.isNotEmpty)
        ? hintTexts!
        : [hintText];

    final searchField = AnimatedHintTextField(
      controller: controller,
      hintTexts: effectiveHintTexts,
      animationType: AnimationType.fade,
      animationDuration: const Duration(milliseconds: 2500),
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            return value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip:
                        context.tr(
                          shared.LocaleKeys.commonDismiss,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'clear search',
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                  )
                : const SizedBox.shrink();
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: onFilterTap == null
          ? searchField
          : Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onFilterTap,
                  icon: const Icon(Icons.filter_alt_outlined, size: 20),
                  label: Text(
                    context.tr(
                          shared.LocaleKeys.commonFilter,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Filter',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
