import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart'
    as assets_gen;

class BusinessLogoPickerCard extends StatelessWidget {
  final ValueListenable<String?> logoPathNotifier;
  final ValueChanged<String?> onLogoChanged;

  const BusinessLogoPickerCard({
    super.key,
    required this.logoPathNotifier,
    required this.onLogoChanged,
  });

  Future<void> _pickLogo(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (pickedFile != null) {
        onLogoChanged(pickedFile.path);
      }
    } catch (e) {
      if (context.mounted) {
        shared.SnackBarUtils.showError(
          context,
          message: 'Error selecting logo image: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: logoPathNotifier,
              builder: (context, customLogoPath, _) {
                final bool hasCustomLogo =
                    customLogoPath != null &&
                    customLogoPath.isNotEmpty &&
                    !kIsWeb &&
                    File(customLogoPath).existsSync();

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: hasCustomLogo
                            ? Image.file(
                                File(customLogoPath),
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                              )
                            : Image.asset(
                                assets_gen.Assets.images.appLogoClearBg.path,
                                fit: BoxFit.contain,
                                width: 80,
                                height: 80,
                              ),
                      ),
                    ),
                    if (hasCustomLogo)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: InkWell(
                          onTap: () => onLogoChanged(null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                          shared.LocaleKeys.settingsBusinessProfileLogoLabel,
                          track: shared.TrackConstants.settingTrack,
                        ) ??
                        'Cafe Logo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(
                          shared.LocaleKeys.settingsBusinessProfileLogoSubtitle,
                          track: shared.TrackConstants.settingTrack,
                        ) ??
                        'Used across printed receipts, PDF invoices, and QR cards',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _pickLogo(context),
                        icon: const Icon(Icons.photo_library_outlined, size: 16),
                        label: Text(
                          context.tr(
                                shared.LocaleKeys.settingsBusinessProfileChangeLogo,
                                track: shared.TrackConstants.settingTrack,
                              ) ??
                              'Change Logo',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ValueListenableBuilder<String?>(
                        valueListenable: logoPathNotifier,
                        builder: (context, customPath, _) {
                          if (customPath == null || customPath.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () => onLogoChanged(null),
                            icon: const Icon(Icons.restart_alt_rounded, size: 16),
                            label: Text(
                              context.tr(
                                    shared
                                        .LocaleKeys
                                        .settingsBusinessProfileRemoveLogo,
                                    track: shared.TrackConstants.settingTrack,
                                  ) ??
                                  'Reset to Default Logo',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
