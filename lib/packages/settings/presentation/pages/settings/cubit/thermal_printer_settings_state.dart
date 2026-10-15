part of 'thermal_printer_settings_cubit.dart';

sealed class ThermalPrinterSettingsState extends Equatable {
  const ThermalPrinterSettingsState();

  @override
  List<Object?> get props => [];
}

class ThermalPrinterSettingsInitial extends ThermalPrinterSettingsState {
  const ThermalPrinterSettingsInitial();
}

class ThermalPrinterSettingsLoading extends ThermalPrinterSettingsState {
  const ThermalPrinterSettingsLoading();
}

class ThermalPrinterSettingsLoaded extends ThermalPrinterSettingsState {
  final ThermalPrinterConfig customerReceiptConfig;
  final ThermalPrinterConfig kitchenStationConfig;
  final List<BluetoothInfo> pairedBluetoothDevices;
  final bool isScanningBluetooth;
  final bool isBluetoothEnabled;
  final bool isBluetoothPermissionGranted;
  final List<UsbPrinterDevice> usbPrinters;
  final bool isScanningUsb;

  const ThermalPrinterSettingsLoaded({
    required this.customerReceiptConfig,
    required this.kitchenStationConfig,
    this.pairedBluetoothDevices = const [],
    this.isScanningBluetooth = false,
    this.isBluetoothEnabled = true,
    this.isBluetoothPermissionGranted = true,
    this.usbPrinters = const [],
    this.isScanningUsb = false,
  });

  ThermalPrinterSettingsLoaded copyWith({
    ThermalPrinterConfig? customerReceiptConfig,
    ThermalPrinterConfig? kitchenStationConfig,
    List<BluetoothInfo>? pairedBluetoothDevices,
    bool? isScanningBluetooth,
    bool? isBluetoothEnabled,
    bool? isBluetoothPermissionGranted,
    List<UsbPrinterDevice>? usbPrinters,
    bool? isScanningUsb,
  }) {
    return ThermalPrinterSettingsLoaded(
      customerReceiptConfig:
          customerReceiptConfig ?? this.customerReceiptConfig,
      kitchenStationConfig: kitchenStationConfig ?? this.kitchenStationConfig,
      pairedBluetoothDevices:
          pairedBluetoothDevices ?? this.pairedBluetoothDevices,
      isScanningBluetooth: isScanningBluetooth ?? this.isScanningBluetooth,
      isBluetoothEnabled: isBluetoothEnabled ?? this.isBluetoothEnabled,
      isBluetoothPermissionGranted:
          isBluetoothPermissionGranted ?? this.isBluetoothPermissionGranted,
      usbPrinters: usbPrinters ?? this.usbPrinters,
      isScanningUsb: isScanningUsb ?? this.isScanningUsb,
    );
  }

  @override
  List<Object?> get props => [
    customerReceiptConfig,
    kitchenStationConfig,
    pairedBluetoothDevices,
    isScanningBluetooth,
    isBluetoothEnabled,
    isBluetoothPermissionGranted,
    usbPrinters,
    isScanningUsb,
  ];
}

class ThermalPrinterSettingsError extends ThermalPrinterSettingsState {
  final String message;

  const ThermalPrinterSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
