import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart' as ftp;
import 'package:flutter_thermal_printer/printer_manager.dart' as ftp_mgr;
import 'package:flutter_thermal_printer/utils/printer.dart' as ftp_prn;

import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

import '../entities/thermal_printer_config.dart';
import '../entities/usb_printer_device.dart';
import 'thermal_usb_driver_interface.dart';

class ThermalUsbDriverImpl implements ThermalUsbDriver {
  const ThermalUsbDriverImpl();

  @override
  Future<List<UsbPrinterDevice>> getUsbPrinters() async {
    try {
      if (kIsWeb) return [];
      final printers = <UsbPrinterDevice>[];
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
                  printers.add(
                    UsbPrinterDevice(
                      name: p.name,
                      vendorId: p.vendorId,
                      productId: p.productId,
                    ),
                  );
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
        ThermalUsbDriverImpl,
        'Error listing USB printers via flutter_thermal_printer: $e',
      );
      return [];
    }
  }

  @override
  Future<bool> printOverUsb({
    required ThermalPrinterConfig config,
    required List<int> bytes,
  }) async {
    if (kIsWeb) {
      core.PlatformUtils.debugLog(
        ThermalUsbDriverImpl,
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
        ThermalUsbDriverImpl,
        'Successfully printed ${bytes.length} bytes to USB Printer (${config.usbName})',
      );
      return true;
    } catch (e) {
      core.PlatformUtils.debugLog(
        ThermalUsbDriverImpl,
        'Error during USB print via flutter_thermal_printer: $e',
      );
      return false;
    }
  }
}

ThermalUsbDriver getThermalUsbDriver() => const ThermalUsbDriverImpl();
