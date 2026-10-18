import 'dart:convert';
import 'package:equatable/equatable.dart';

enum DeviceSyncRole {
  posHub, // Runs local server & UDP beacon; authoritative order store
  clientTerminal, // Waiter / KDS tablet; connects to POS Hub via Wi-Fi
  disabled, // Offline sync turned off
}

enum SyncConnectionStatus {
  idle,
  discovering,
  connecting,
  hosting,
  connected,
  disconnected,
  error,
}

class P2pSyncConfig extends Equatable {
  final DeviceSyncRole role;
  final String deviceName;
  final String hubIpAddress;
  final int hubPort;
  final bool autoDiscover;
  final bool isEnabled;

  const P2pSyncConfig({
    this.role = DeviceSyncRole.disabled,
    this.deviceName = 'Station',
    this.hubIpAddress = '',
    this.hubPort = 8899,
    this.autoDiscover = true,
    this.isEnabled = false,
  });

  P2pSyncConfig copyWith({
    DeviceSyncRole? role,
    String? deviceName,
    String? hubIpAddress,
    int? hubPort,
    bool? autoDiscover,
    bool? isEnabled,
  }) {
    return P2pSyncConfig(
      role: role ?? this.role,
      deviceName: deviceName ?? this.deviceName,
      hubIpAddress: hubIpAddress ?? this.hubIpAddress,
      hubPort: hubPort ?? this.hubPort,
      autoDiscover: autoDiscover ?? this.autoDiscover,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role.name,
      'deviceName': deviceName,
      'hubIpAddress': hubIpAddress,
      'hubPort': hubPort,
      'autoDiscover': autoDiscover,
      'isEnabled': isEnabled,
    };
  }

  factory P2pSyncConfig.fromMap(Map<String, dynamic> map) {
    return P2pSyncConfig(
      role: DeviceSyncRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => DeviceSyncRole.disabled,
      ),
      deviceName: map['deviceName'] as String? ?? 'Station',
      hubIpAddress: map['hubIpAddress'] as String? ?? '',
      hubPort: (map['hubPort'] as num?)?.toInt() ?? 8899,
      autoDiscover: map['autoDiscover'] as bool? ?? true,
      isEnabled: map['isEnabled'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory P2pSyncConfig.fromJson(String source) {
    try {
      return P2pSyncConfig.fromMap(jsonDecode(source) as Map<String, dynamic>);
    } catch (_) {
      return const P2pSyncConfig();
    }
  }

  @override
  List<Object?> get props => [
    role,
    deviceName,
    hubIpAddress,
    hubPort,
    autoDiscover,
    isEnabled,
  ];
}
