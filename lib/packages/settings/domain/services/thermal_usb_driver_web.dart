import '../entities/thermal_printer_config.dart';
import '../entities/usb_printer_device.dart';
import 'thermal_usb_driver_interface.dart';

class ThermalUsbDriverImpl implements ThermalUsbDriver {
  const ThermalUsbDriverImpl();

  @override
  Future<List<UsbPrinterDevice>> getUsbPrinters() async => [];

  @override
  Future<bool> printOverUsb({
    required ThermalPrinterConfig config,
    required List<int> bytes,
  }) async => false;
}

ThermalUsbDriver getThermalUsbDriver() => const ThermalUsbDriverImpl();
