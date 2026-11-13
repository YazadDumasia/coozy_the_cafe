import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class PdfViewerViewport extends StatelessWidget {
  final Uint8List? pdfBytes;
  final bool isLoading;
  final String? loadingAnimationPath;
  final String? loadingMessage;
  final String? errorMessage;
  final PdfViewerController? controller;

  const PdfViewerViewport({
    super.key,
    required this.pdfBytes,
    required this.isLoading,
    this.loadingAnimationPath,
    this.loadingMessage,
    this.errorMessage,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      final defaultAnimation = theme.brightness == Brightness.dark
          ? Assets.lottie.qrcodeDark
          : Assets.lottie.qrcodeLight;

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              loadingAnimationPath ?? defaultAnimation,
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 12),
            Text(
              loadingMessage ??
                  (context.tr(
                        shared.LocaleKeys.commonPleaseWait,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Please wait...'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (pdfBytes != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SfPdfViewer.memory(
          pdfBytes!,
          controller: controller,
          canShowScrollHead: false,
          canShowScrollStatus: false,
          onDocumentLoadFailed: (details) {
            core.PlatformUtils.debugLog(
              PdfViewerViewport,
              'SfPdfViewer load failed: ${details.error} - ${details.description}',
            );
          },
        ),
      );
    }

    return Center(
      child: Text(
        errorMessage ??
            (context.tr(
                  shared.LocaleKeys.commonErrorMsg,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Failed to render PDF preview'),
        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.error),
      ),
    );
  }
}
