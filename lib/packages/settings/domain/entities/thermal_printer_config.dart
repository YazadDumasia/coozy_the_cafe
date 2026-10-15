import 'dart:convert';

import 'package:equatable/equatable.dart';

enum ThermalPrinterType { network, bluetooth, usb, systemSpooler }

enum ThermalPaperSize { mm58, mm80 }

class ThermalPrinterConfig extends Equatable {
  final ThermalPrinterType type;
  final String ipAddress;
  final int port;
  final String bluetoothAddress;
  final String bluetoothName;
  final String usbName;
  final String usbVendorId;
  final String usbProductId;
  final ThermalPaperSize paperSize;
  final bool isEnabled;

  const ThermalPrinterConfig({
    this.type = ThermalPrinterType.systemSpooler,
    this.ipAddress = '192.168.1.200',
    this.port = 9100,
    this.bluetoothAddress = '',
    this.bluetoothName = '',
    this.usbName = '',
    this.usbVendorId = '',
    this.usbProductId = '',
    this.paperSize = ThermalPaperSize.mm80,
    this.isEnabled = false,
  });

  ThermalPrinterConfig copyWith({
    ThermalPrinterType? type,
    String? ipAddress,
    int? port,
    String? bluetoothAddress,
    String? bluetoothName,
    String? usbName,
    String? usbVendorId,
    String? usbProductId,
    ThermalPaperSize? paperSize,
    bool? isEnabled,
  }) {
    return ThermalPrinterConfig(
      type: type ?? this.type,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      bluetoothAddress: bluetoothAddress ?? this.bluetoothAddress,
      bluetoothName: bluetoothName ?? this.bluetoothName,
      usbName: usbName ?? this.usbName,
      usbVendorId: usbVendorId ?? this.usbVendorId,
      usbProductId: usbProductId ?? this.usbProductId,
      paperSize: paperSize ?? this.paperSize,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'ipAddress': ipAddress,
      'port': port,
      'bluetoothAddress': bluetoothAddress,
      'bluetoothName': bluetoothName,
      'usbName': usbName,
      'usbVendorId': usbVendorId,
      'usbProductId': usbProductId,
      'paperSize': paperSize.name,
      'isEnabled': isEnabled,
    };
  }

  factory ThermalPrinterConfig.fromMap(Map<String, dynamic> map) {
    return ThermalPrinterConfig(
      type: ThermalPrinterType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ThermalPrinterType.systemSpooler,
      ),
      ipAddress: map['ipAddress'] as String? ?? '192.168.1.200',
      port: (map['port'] as num?)?.toInt() ?? 9100,
      bluetoothAddress: map['bluetoothAddress'] as String? ?? '',
      bluetoothName: map['bluetoothName'] as String? ?? '',
      usbName: map['usbName'] as String? ?? '',
      usbVendorId: map['usbVendorId'] as String? ?? '',
      usbProductId: map['usbProductId'] as String? ?? '',
      paperSize: ThermalPaperSize.values.firstWhere(
        (e) => e.name == map['paperSize'],
        orElse: () => ThermalPaperSize.mm80,
      ),
      isEnabled: map['isEnabled'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ThermalPrinterConfig.fromJson(String source) {
    try {
      return ThermalPrinterConfig.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );
    } catch (_) {
      return const ThermalPrinterConfig();
    }
  }

  @override
  List<Object?> get props => [
    type,
    ipAddress,
    port,
    bluetoothAddress,
    bluetoothName,
    usbName,
    usbVendorId,
    usbProductId,
    paperSize,
    isEnabled,
  ];
}
