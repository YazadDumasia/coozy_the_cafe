import 'thermal_usb_driver_interface.dart';
import 'thermal_usb_driver_web.dart'
    if (dart.library.io) 'thermal_usb_driver_io.dart';

export 'thermal_usb_driver_interface.dart';

ThermalUsbDriver createThermalUsbDriver() => getThermalUsbDriver();
