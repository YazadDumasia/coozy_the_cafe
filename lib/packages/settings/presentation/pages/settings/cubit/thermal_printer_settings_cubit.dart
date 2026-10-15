import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/usb_printer_device.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../../domain/entities/thermal_printer_config.dart';
import '../../../../domain/services/thermal_printer_service.dart';

part 'thermal_printer_settings_state.dart';

class ThermalPrinterSettingsCubit extends Cubit<ThermalPrinterSettingsState> {
  final ThermalPrinterService printerService;

  ThermalPrinterSettingsCubit({required this.printerService})
    : super(const ThermalPrinterSettingsInitial());

  Future<void> loadSettings() async {
    emit(const ThermalPrinterSettingsLoading());
    try {
      final customerConfig = await printerService.getPrinterConfig(
        stationKey: shared.PreferencesKeys.customerReceiptPrinterConfig,
      );
      final kitchenConfig = await printerService.getPrinterConfig(
        stationKey: shared.PreferencesKeys.kitchenStationPrinterConfig,
      );

      final hasPermission =
          await printerService.requestBluetoothPermissions();
      final isBtEnabled = await printerService.isBluetoothEnabled();
      final bluetoothDevices = isBtEnabled
          ? await printerService.getPairedBluetoothDevices()
          : <BluetoothInfo>[];
      final usbDevices = await printerService.getUsbPrinters();

      emit(
        ThermalPrinterSettingsLoaded(
          customerReceiptConfig: customerConfig,
          kitchenStationConfig: kitchenConfig,
          pairedBluetoothDevices: bluetoothDevices,
          isBluetoothEnabled: isBtEnabled,
          isBluetoothPermissionGranted: hasPermission,
          usbPrinters: usbDevices,
        ),
      );
    } catch (e) {
      emit(ThermalPrinterSettingsError('Failed to load printer settings: $e'));
    }
  }

  Future<void> refreshBluetoothDevices() async {
    if (state is! ThermalPrinterSettingsLoaded) return;
    final currentState = state as ThermalPrinterSettingsLoaded;
    emit(currentState.copyWith(isScanningBluetooth: true));
    try {
      final hasPermission =
          await printerService.requestBluetoothPermissions();
      final isBtEnabled = await printerService.isBluetoothEnabled();
      final devices = isBtEnabled
          ? await printerService.getPairedBluetoothDevices()
          : <BluetoothInfo>[];
      emit(
        currentState.copyWith(
          pairedBluetoothDevices: devices,
          isBluetoothEnabled: isBtEnabled,
          isBluetoothPermissionGranted: hasPermission,
          isScanningBluetooth: false,
        ),
      );
    } catch (_) {
      emit(currentState.copyWith(isScanningBluetooth: false));
    }
  }

  Future<void> requestBluetoothPermission() async {
    await printerService.requestBluetoothPermissions();
    await refreshBluetoothDevices();
  }

  Future<void> refreshUsbDevices() async {
    if (state is! ThermalPrinterSettingsLoaded) return;
    final currentState = state as ThermalPrinterSettingsLoaded;
    emit(currentState.copyWith(isScanningUsb: true));
    try {
      final devices = await printerService.getUsbPrinters();
      emit(currentState.copyWith(usbPrinters: devices, isScanningUsb: false));
    } catch (_) {
      emit(currentState.copyWith(isScanningUsb: false));
    }
  }

  Future<void> updateCustomerConfig(ThermalPrinterConfig newConfig) async {
    if (state is! ThermalPrinterSettingsLoaded) return;
    final currentState = state as ThermalPrinterSettingsLoaded;
    await printerService.savePrinterConfig(
      stationKey: shared.PreferencesKeys.customerReceiptPrinterConfig,
      config: newConfig,
    );
    emit(currentState.copyWith(customerReceiptConfig: newConfig));
  }

  Future<void> updateKitchenConfig(ThermalPrinterConfig newConfig) async {
    if (state is! ThermalPrinterSettingsLoaded) return;
    final currentState = state as ThermalPrinterSettingsLoaded;
    await printerService.savePrinterConfig(
      stationKey: shared.PreferencesKeys.kitchenStationPrinterConfig,
      config: newConfig,
    );
    emit(currentState.copyWith(kitchenStationConfig: newConfig));
  }

  Future<bool> sendTestPrint({required bool isKitchenStation}) async {
    if (state is! ThermalPrinterSettingsLoaded) return false;
    final currentState = state as ThermalPrinterSettingsLoaded;
    final config = isKitchenStation
        ? currentState.kitchenStationConfig
        : currentState.customerReceiptConfig;
    final stationName = isKitchenStation
        ? 'Kitchen KOT Station'
        : 'Customer Receipt Station';

    return await printerService.sendTestPrint(
      config: config,
      stationName: stationName,
    );
  }
}
