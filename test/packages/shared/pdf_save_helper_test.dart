import 'dart:io';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (MethodCall call) async {
      return Directory.systemTemp.path;
    });
  });

  group('PdfSaveHelper and checkPdfStoragePermission tests', () {
    test('PdfSaveResult.success creates correct success object', () {
      final result = PdfSaveResult.success(filePath: '/path/to/test.pdf');
      expect(result.isSuccess, isTrue);
      expect(result.filePath, '/path/to/test.pdf');
      expect(result.isWeb, isFalse);
      expect(result.errorMessage, isNull);
    });

    test('PdfSaveResult.failure creates correct failure object', () {
      final result = PdfSaveResult.failure('Permission denied');
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, 'Permission denied');
      expect(result.filePath, isNull);
    });

    test('checkPdfStoragePermission returns true on non-Android/desktop test runner', () async {
      final granted = await checkPdfStoragePermission();
      expect(granted, isTrue);
    });

    test('PdfSaveHelper.checkPdfStoragePermission matches top-level checkPdfStoragePermission', () async {
      final granted = await PdfSaveHelper.checkPdfStoragePermission();
      expect(granted, isTrue);
    });

    test('PdfSaveHelper.saveInvoicePdf saves invoice PDF bytes and returns success', () async {
      final bytes = Uint8List.fromList([37, 80, 68, 70]); // %PDF
      final result = await PdfSaveHelper.saveInvoicePdf(
        bytes: bytes,
        invoiceNumber: 'MD-11788',
      );
      expect(result.isSuccess, isTrue);
      expect(result.filePath, contains('Invoice_MD-11788.pdf'));
    });
  });
}
