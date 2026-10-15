import '../entities/thermal_printer_config.dart';
import '../entities/usb_printer_device.dart';

abstract class ThermalUsbDriver {
  Future<List<UsbPrinterDevice>> getUsbPrinters();
  Future<bool> printOverUsb({
    required ThermalPrinterConfig config,
    required List<int> bytes,
  });
}
