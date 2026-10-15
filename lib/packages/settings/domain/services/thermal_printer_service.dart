import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart' as ftp;
import 'package:flutter_thermal_printer/printer_manager.dart' as ftp_mgr;
import 'package:flutter_thermal_printer/utils/printer.dart' as ftp_prn;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../entities/thermal_printer_config.dart';

/// Service responsible for communicating with ESC/POS Network, Bluetooth, USB,
/// and System Spooler thermal printers.
class ThermalPrinterService {
  ThermalPrinterService._();

  static final ThermalPrinterService instance = ThermalPrinterService._();

  /// Retrieves saved printer config for the specified station key.
  Future<ThermalPrinterConfig> getPrinterConfig({
    required shared.PreferencesKeys stationKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(stationKey.name);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const ThermalPrinterConfig();
    }
    return ThermalPrinterConfig.fromJson(jsonStr);
  }

  /// Saves printer config for the specified station key.
  Future<void> savePrinterConfig({
    required shared.PreferencesKeys stationKey,
    required ThermalPrinterConfig config,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(stationKey.name, config.toJson());
  }

  /// Requests necessary Bluetooth permissions for Android 12+ and legacy Android.
  Future<bool> requestBluetoothPermissions() async {
    if (kIsWeb) return false;
    try {
      final bool granted =
          await PrintBluetoothThermal.isPermissionBluetoothGranted;
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'PrintBluetoothThermal.isPermissionBluetoothGranted: $granted',
      );
      return granted;
    } catch (e) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Error requesting Bluetooth permissions: $e',
      );
      return false;
    }
  }

  /// Checks if Bluetooth is turned on.
  Future<bool> isBluetoothEnabled() async {
    if (kIsWeb) return false;
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Error checking bluetoothEnabled: $e',
      );
      return false;
    }
  }

  /// Fetches paired/scanned Bluetooth devices (SPP / Thermal Bluetooth).
  Future<List<BluetoothInfo>> getPairedBluetoothDevices() async {
    try {
      if (kIsWeb) return [];
      await requestBluetoothPermissions();
      final bool enabled = await isBluetoothEnabled();
      if (!enabled) {
        core.PlatformUtils.debugLog(
          ThermalPrinterService,
          'Bluetooth is currently disabled on device.',
        );
        return [];
      }
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Found ${devices.length} paired Bluetooth devices.',
      );
      return devices;
    } catch (e) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Error listing Bluetooth devices: $e',
      );
      return [];
    }
  }

  /// Fetches USB and thermal printers via flutter_thermal_printer.
  Future<List<ftp_prn.Printer>> getUsbPrinters() async {
    try {
      if (kIsWeb) return [];
      final printers = <ftp_prn.Printer>[];
      final subscription = ftp.FlutterThermalPrinter.instance.devicesStream
          .listen((list) {
            for (final p in list) {
              if (p.connectionType == ftp_prn.ConnectionType.USB ||
                  p.vendorId != null ||
                  p.productId != null) {
                if (!printers.any(
                  (existing) =>
                      existing.vendorId == p.vendorId &&
                      existing.productId == p.productId &&
                      existing.name == p.name,
                )) {
                  printers.add(p);
                }
              }
            }
          });

      await ftp.FlutterThermalPrinter.instance.getPrinters(
        refreshDuration: const Duration(seconds: 1),
        connectionTypes: [ftp_prn.ConnectionType.USB],
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      await subscription.cancel();
      return printers;
    } catch (e) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Error listing USB printers via flutter_thermal_printer: $e',
      );
      return [];
    }
  }

  /// Sends raw ESC/POS bytes to the printer configured for [stationKey].
  /// Returns `true` on successful transmission.
  Future<bool> printBytes({
    required shared.PreferencesKeys stationKey,
    required List<int> bytes,
    String jobName = 'Thermal Print Job',
  }) async {
    final config = await getPrinterConfig(stationKey: stationKey);
    return printBytesWithConfig(config: config, bytes: bytes, jobName: jobName);
  }

  /// Sends raw ESC/POS bytes directly using the specified [config].
  Future<bool> printBytesWithConfig({
    required ThermalPrinterConfig config,
    required List<int> bytes,
    String jobName = 'Thermal Print Job',
  }) async {
    switch (config.type) {
      case ThermalPrinterType.network:
        return _printOverNetwork(
          ip: config.ipAddress,
          port: config.port,
          bytes: bytes,
        );

      case ThermalPrinterType.bluetooth:
        return _printOverBluetooth(
          macAddress: config.bluetoothAddress,
          bytes: bytes,
        );

      case ThermalPrinterType.usb:
        return _printOverUsb(config: config, bytes: bytes);

      case ThermalPrinterType.systemSpooler:
        return _printViaSystemSpooler(
          bytes: bytes,
          is58mm: config.paperSize == ThermalPaperSize.mm58,
          jobName: jobName,
        );
    }
  }

  /// Sends bytes over USB using flutter_thermal_printer
  Future<bool> _printOverUsb({
    required ThermalPrinterConfig config,
    required List<int> bytes,
  }) async {
    if (kIsWeb) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'USB Thermal printing not available on Web.',
      );
      return false;
    }
    try {
      final usbPrinter = ftp_prn.Printer(
        name: config.usbName.isNotEmpty
            ? config.usbName
            : 'USB Thermal Printer',
        vendorId: config.usbVendorId.isNotEmpty ? config.usbVendorId : null,
        productId: config.usbProductId.isNotEmpty ? config.usbProductId : null,
        connectionType: ftp_prn.ConnectionType.USB,
      );

      final isConnected = await ftp_mgr.PrinterManager.instance.isConnected(
        usbPrinter,
      );
      if (!isConnected) {
        await ftp.FlutterThermalPrinter.instance.connect(usbPrinter);
      }

      await ftp.FlutterThermalPrinter.instance.printData(
        usbPrinter,
        bytes,
        longData: true,
      );

      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Successfully printed ${bytes.length} bytes to USB Printer (${config.usbName})',
      );
      return true;
    } catch (e) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Error during USB print via flutter_thermal_printer: $e',
      );
      return false;
    }
  }

  /// Sends bytes over raw TCP socket (port 9100 standard raw port)
  Future<bool> _printOverNetwork({
    required String ip,
    required int port,
    required List<int> bytes,
  }) async {
    if (kIsWeb) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Direct TCP Raw Socket printing is not supported on Web. Please use System Spooler.',
      );
      return false;
    }
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.add(bytes);
      await socket.flush();
      await socket.close();
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Successfully printed ${bytes.length} bytes to Network Printer $ip:$port',
      );
      return true;
    } catch (e) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Failed to print over network ($ip:$port): $e',
      );
      socket?.destroy();
      return false;
    }
  }

  /// Sends bytes over Bluetooth Serial / SPP via [PrintBluetoothThermal]
  Future<bool> _printOverBluetooth({
    required String macAddress,
    required List<int> bytes,
  }) async {
    if (kIsWeb) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Bluetooth Thermal printing not available on Web.',
      );
      return false;
    }
    try {
      final bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (!isConnected && macAddress.isNotEmpty) {
        final bool connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: macAddress,
        );
        if (!connected) {
          core.PlatformUtils.debugLog(
            ThermalPrinterService,
            'Failed to connect to Bluetooth printer: $macAddress',
          );
          return false;
        }
      }

      final bool result = await PrintBluetoothThermal.writeBytes(bytes);
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Bluetooth print result: $result for ${bytes.length} bytes',
      );
      return result;
    } catch (e) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Error during Bluetooth print: $e',
      );
      return false;
    }
  }

  /// Universal fallback: Converts raw ESC/POS or text into system layout PDF
  Future<bool> _printViaSystemSpooler({
    required List<int> bytes,
    required bool is58mm,
    required String jobName,
  }) async {
    try {
      final document = PdfDocument();
      // Estimate printable width: 58mm = ~164 pt, 80mm = ~226 pt
      final rollWidth = is58mm ? 164.0 : 226.0;
      final textContent = _extractPrintableText(bytes);
      final lines = textContent.split('\n');

      // Calculate needed height dynamically based on line count
      final calculatedHeight = (lines.length * 13.0 + 40.0).clamp(
        200.0,
        4000.0,
      );

      document.pageSettings.size = Size(rollWidth, calculatedHeight);
      document.pageSettings.margins.all = 8;

      final page = document.pages.add();
      final font = PdfStandardFont(PdfFontFamily.courier, 8.5);

      page.graphics.drawString(
        textContent,
        font,
        bounds: Rect.fromLTWH(0, 0, rollWidth - 16, calculatedHeight - 16),
      );

      final pdfBytes = Uint8List.fromList(document.saveSync());
      document.dispose();

      await Printing.layoutPdf(onLayout: (_) async => pdfBytes, name: jobName);
      return true;
    } catch (e) {
      core.PlatformUtils.debugLog(
        ThermalPrinterService,
        'Error during System Spooler print: $e',
      );
      return false;
    }
  }

  /// Utility to filter ESC/POS control characters into printable ASCII / UTF-8 text for spooler
  String _extractPrintableText(List<int> bytes) {
    final buffer = StringBuffer();
    for (int i = 0; i < bytes.length; i++) {
      final b = bytes[i];
      if (b == 0x0A) {
        buffer.write('\n');
      } else if (b >= 0x20 && b <= 0x7E) {
        buffer.writeCharCode(b);
      }
    }
    return buffer.toString();
  }

  /// Sends a test print ticket to the given printer configuration
  Future<bool> sendTestPrint({
    required ThermalPrinterConfig config,
    required String stationName,
  }) async {
    final paper = config.paperSize == ThermalPaperSize.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final generator = Generator(paper, profile);

    List<int> bytes = [];
    bytes += generator.reset();
    bytes += generator.text(
      'COOZY THE CAFE',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Thermal Printer Test',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
        text: 'Station:',
        width: 4,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(text: stationName, width: 8),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Type:', width: 4, styles: const PosStyles(bold: true)),
      PosColumn(text: config.type.name.toUpperCase(), width: 8),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Paper Size:',
        width: 4,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: config.paperSize == ThermalPaperSize.mm58 ? '58mm' : '80mm',
        width: 8,
      ),
    ]);
    if (config.type == ThermalPrinterType.network) {
      bytes += generator.row([
        PosColumn(
          text: 'IP / Port:',
          width: 4,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(text: '${config.ipAddress}:${config.port}', width: 8),
      ]);
    } else if (config.type == ThermalPrinterType.bluetooth) {
      bytes += generator.row([
        PosColumn(
          text: 'Bluetooth:',
          width: 4,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: config.bluetoothName.isNotEmpty
              ? config.bluetoothName
              : config.bluetoothAddress,
          width: 8,
        ),
      ]);
    } else if (config.type == ThermalPrinterType.usb) {
      bytes += generator.row([
        PosColumn(
          text: 'USB Printer:',
          width: 4,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: config.usbName.isNotEmpty
              ? config.usbName
              : 'VID:${config.usbVendorId} PID:${config.usbProductId}',
          width: 8,
        ),
      ]);
    }
    bytes += generator.hr();
    bytes += generator.feed(1);
    bytes += generator.text(
      'SUCCESSFUL CONNECTION TEST',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    return printBytesWithConfig(
      config: config,
      bytes: bytes,
      jobName: 'Test Print - $stationName',
    );
  }
}
