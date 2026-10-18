part of 'p2p_sync_settings_cubit.dart';

sealed class P2pSyncSettingsState extends Equatable {
  const P2pSyncSettingsState();

  @override
  List<Object?> get props => [];
}

final class P2pSyncSettingsInitial extends P2pSyncSettingsState {
  const P2pSyncSettingsInitial();
}

final class P2pSyncSettingsLoading extends P2pSyncSettingsState {
  const P2pSyncSettingsLoading();
}

final class P2pSyncSettingsSaving extends P2pSyncSettingsState {
  const P2pSyncSettingsSaving();
}

final class P2pSyncSettingsLoaded extends P2pSyncSettingsState {
  final P2pSyncConfig config;
  final String localIp;
  final SyncConnectionStatus status;
  final int clientCount;

  const P2pSyncSettingsLoaded({
    required this.config,
    required this.localIp,
    required this.status,
    required this.clientCount,
  });

  @override
  List<Object?> get props => [config, localIp, status, clientCount];
}

final class P2pSyncSettingsError extends P2pSyncSettingsState {
  final String message;

  const P2pSyncSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
