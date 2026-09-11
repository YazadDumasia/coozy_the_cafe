import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/coozy_core.dart' as core;

/// Result object returned by [PdfSaveHelper.saveAndDownloadPdf].
class PdfSaveResult {
  final bool isSuccess;
  final String? filePath;
  final String? errorMessage;
  final bool isWeb;

  const PdfSaveResult({
    required this.isSuccess,
    this.filePath,
    this.errorMessage,
    this.isWeb = false,
  });

  factory PdfSaveResult.success({
    required String filePath,
    bool isWeb = false,
  }) {
    return PdfSaveResult(
      isSuccess: true,
      filePath: filePath,
      isWeb: isWeb,
    );
  }

  factory PdfSaveResult.failure(String errorMessage) {
    return PdfSaveResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Helper utility for saving, downloading, and sharing PDF files across
/// all supported platforms (Web, Android, iOS, Windows, macOS, Linux).
class PdfSaveHelper {
  /// Saves and downloads PDF bytes to the local file system.
  ///
  /// - On **Web**: delegates to [Printing.sharePdf], which initiates a browser download blob.
  /// - On **Android**: attempts writing directly to the public Downloads directory (`/storage/emulated/0/Download`).
  ///   If restricted (e.g. Android 10+ scoped storage without broad access),
  ///   falls back to app-specific external downloads storage, external storage,
  ///   or application documents directory.
  /// - On **iOS**: writes to [getApplicationDocumentsDirectory].
  /// - On **Desktop**: writes to [getDownloadsDirectory] or [getApplicationDocumentsDirectory].
  static Future<PdfSaveResult> saveAndDownloadPdf({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      if (kIsWeb) {
        await Printing.sharePdf(
          bytes: bytes,
          filename: filename,
        );
        return PdfSaveResult.success(
          filePath: filename,
          isWeb: true,
        );
      }

      if (Platform.isAndroid) {
        return await _saveForAndroid(bytes, filename);
      } else if (Platform.isIOS) {
        return await _saveForIOS(bytes, filename);
      } else {
        return await _saveForDesktop(bytes, filename);
      }
    } catch (e, stack) {
      core.PlatformUtils.debugLog(
        PdfSaveHelper,
        'Error saving PDF ($filename): $e\n$stack',
      );
      return PdfSaveResult.failure(e.toString());
    }
  }

  /// Checks and requests storage permission on mobile platforms (Android).
  ///
  /// - On **Android 13 (API 33) and above**: granular media permissions apply and
  ///   classic storage permission is deprecated; returns `true` immediately.
  /// - On **Android 12 and below**: requests [Permission.storage].
  /// - On **iOS, Web & Desktop**: returns `true`.
  static Future<bool> checkPdfStoragePermission() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      try {
        final AndroidDeviceInfo androidInfo =
            await DeviceInfoPlugin().androidInfo;

        // Android 13 (API 33) and above
        if (androidInfo.version.sdkInt >= 33) {
          // If you are just using Option 1 or 2, return true immediately.
          // If you strictly need all-file scanning (Option 3):
          // return await Permission.manageExternalStorage.request().isGranted;
          return true;
        }
        // Android 12 and below (Requires classic storage permission)
        else {
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      } catch (e) {
        core.PlatformUtils.debugLog(
          PdfSaveHelper,
          'Storage permission request error: $e',
        );
        return false;
      }
    }
    return true; // iOS handles sandbox differently or uses the Files app picker
  }

  /// Checks and requests storage permission on mobile platforms (Android).
  /// Alias for [checkPdfStoragePermission].
  static Future<bool> requestStoragePermission() => checkPdfStoragePermission();

  static Future<PdfSaveResult> _saveForAndroid(
    Uint8List bytes,
    String filename,
  ) async {
    // 1. Explicitly ask for storage permission on mobile
    final bool hasPermission = await requestStoragePermission();
    core.PlatformUtils.debugLog(
      PdfSaveHelper,
      'Android storage permission status: $hasPermission',
    );

    // 2. Attempt writing to public Downloads folder directly
    try {
      final Directory publicDownloadDir = Directory('/storage/emulated/0/Download');
      if (await publicDownloadDir.exists()) {
        final File file = File('${publicDownloadDir.path}${Platform.pathSeparator}$filename');
        await file.writeAsBytes(bytes, flush: true);
        core.PlatformUtils.debugLog(
          PdfSaveHelper,
          'Saved PDF to Android public Download folder: ${file.path}',
        );
        return PdfSaveResult.success(filePath: file.path);
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        PdfSaveHelper,
        'Public Downloads folder write failed, falling back: $e',
      );
    }

    // 2. Fallback to app external storage Downloads directory (no broad permissions needed)
    try {
      final List<Directory>? extDownloads = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (extDownloads != null && extDownloads.isNotEmpty) {
        final File file = File('${extDownloads.first.path}${Platform.pathSeparator}$filename');
        await file.writeAsBytes(bytes, flush: true);
        core.PlatformUtils.debugLog(
          PdfSaveHelper,
          'Saved PDF to Android app-specific external downloads: ${file.path}',
        );
        return PdfSaveResult.success(filePath: file.path);
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        PdfSaveHelper,
        'App external downloads write failed: $e',
      );
    }

    // 3. Fallback to app external storage root directory
    try {
      final Directory? extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final File file = File('${extDir.path}${Platform.pathSeparator}$filename');
        await file.writeAsBytes(bytes, flush: true);
        core.PlatformUtils.debugLog(
          PdfSaveHelper,
          'Saved PDF to Android app external storage: ${file.path}',
        );
        return PdfSaveResult.success(filePath: file.path);
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        PdfSaveHelper,
        'External storage write failed: $e',
      );
    }

    // 4. Final fallback to application documents directory
    final Directory docDir = await getApplicationDocumentsDirectory();
    final File file = File('${docDir.path}${Platform.pathSeparator}$filename');
    await file.writeAsBytes(bytes, flush: true);
    core.PlatformUtils.debugLog(
      PdfSaveHelper,
      'Saved PDF to application documents directory: ${file.path}',
    );
    return PdfSaveResult.success(filePath: file.path);
  }

  static Future<PdfSaveResult> _saveForIOS(
    Uint8List bytes,
    String filename,
  ) async {
    final Directory docDir = await getApplicationDocumentsDirectory();
    final File file = File('${docDir.path}${Platform.pathSeparator}$filename');
    await file.writeAsBytes(bytes, flush: true);
    core.PlatformUtils.debugLog(
      PdfSaveHelper,
      'Saved PDF to iOS documents directory: ${file.path}',
    );
    return PdfSaveResult.success(filePath: file.path);
  }

  static Future<PdfSaveResult> _saveForDesktop(
    Uint8List bytes,
    String filename,
  ) async {
    Directory? targetDir;
    try {
      targetDir = await getDownloadsDirectory();
    } catch (_) {}
    targetDir ??= await getApplicationDocumentsDirectory();

    final File file = File('${targetDir.path}${Platform.pathSeparator}$filename');
    await file.writeAsBytes(bytes, flush: true);
    core.PlatformUtils.debugLog(
      PdfSaveHelper,
      'Saved PDF to desktop directory: ${file.path}',
    );
    return PdfSaveResult.success(filePath: file.path);
  }

  /// Shares a saved PDF file via the native system share sheet.
  /// Uses [share_plus] on mobile/desktop and [Printing.sharePdf] on web.
  static Future<void> sharePdfFile({
    required String filePath,
    required String filename,
    Uint8List? fallbackBytes,
    Rect? sharePositionOrigin,
  }) async {
    if (kIsWeb) {
      if (fallbackBytes != null) {
        await Printing.sharePdf(
          bytes: fallbackBytes,
          filename: filename,
        );
      }
      return;
    }

    final File file = File(filePath);
    if (await file.exists()) {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              file.path,
              mimeType: 'application/pdf',
              name: filename,
            ),
          ],
          subject: filename,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    } else if (fallbackBytes != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              fallbackBytes,
              mimeType: 'application/pdf',
              name: filename,
            ),
          ],
          subject: filename,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    }
  }

  /// Saves and downloads an invoice PDF.
  static Future<PdfSaveResult> saveInvoicePdf({
    required Uint8List bytes,
    required String invoiceNumber,
  }) async {
    final String cleanNumber =
        invoiceNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
    final String filename = 'Invoice_$cleanNumber.pdf';
    return await saveAndDownloadPdf(bytes: bytes, filename: filename);
  }

  /// Shares an invoice PDF document across Mobile, Desktop, and Web.
  ///
  /// Automatically generates an appropriate invoice filename (`Invoice_<invoiceNumber>.pdf`),
  /// ensures it is saved to device storage on native platforms, and invokes the system share sheet.
  ///
  /// - [bytes]: Binary PDF content of the invoice receipt.
  /// - [invoiceNumber]: Invoice / receipt identifier (e.g. "MD-11788"), used for naming and share subject.
  /// - [filePath]: Optional existing file path if already saved to disk.
  /// - [sharePositionOrigin]: Optional iPad/tablet popup anchor.
  static Future<void> shareInvoice({
    Uint8List? bytes,
    required String invoiceNumber,
    String? filePath,
    Rect? sharePositionOrigin,
  }) async {
    final String cleanNumber =
        invoiceNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
    final String filename = 'Invoice_$cleanNumber.pdf';

    String? targetFilePath = filePath;
    if (targetFilePath == null && bytes != null) {
      final result = await saveAndDownloadPdf(
        bytes: bytes,
        filename: filename,
      );
      targetFilePath = result.filePath;
    }

    await sharePdfFile(
      filePath: targetFilePath ?? filename,
      filename: filename,
      fallbackBytes: bytes,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Alias for [shareInvoice].
  static Future<void> shareInvoicePdf({
    Uint8List? bytes,
    required String invoiceNumber,
    String? filePath,
    Rect? sharePositionOrigin,
  }) =>
      shareInvoice(
        bytes: bytes,
        invoiceNumber: invoiceNumber,
        filePath: filePath,
        sharePositionOrigin: sharePositionOrigin,
      );
}

/// Checks and requests storage permission on mobile platforms (Android).
///
/// - Android 13 (API 33) and above: returns true immediately.
/// - Android 12 and below: requests [Permission.storage].
/// - iOS, Web & Desktop: returns true.
Future<bool> checkPdfStoragePermission() =>
    PdfSaveHelper.checkPdfStoragePermission();

/// Shares an invoice PDF document across Mobile, Desktop, and Web.
Future<void> shareInvoice({
  Uint8List? bytes,
  required String invoiceNumber,
  String? filePath,
  Rect? sharePositionOrigin,
}) =>
    PdfSaveHelper.shareInvoice(
      bytes: bytes,
      invoiceNumber: invoiceNumber,
      filePath: filePath,
      sharePositionOrigin: sharePositionOrigin,
    );
