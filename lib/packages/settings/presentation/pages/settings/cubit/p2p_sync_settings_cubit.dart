import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/p2p_sync_config.dart';
import '../../../../domain/services/local_p2p_sync_service.dart';

part 'p2p_sync_settings_state.dart';

class P2pSyncSettingsCubit extends Cubit<P2pSyncSettingsState> {
  final LocalP2pSyncService syncService;

  P2pSyncSettingsCubit({required this.syncService})
      : super(const P2pSyncSettingsInitial());

  Future<void> loadSettings() async {
    emit(const P2pSyncSettingsLoading());
    try {
      final config = syncService.currentConfig;
      final localIp = await syncService.getLocalIpAddress() ?? '';
      emit(
        P2pSyncSettingsLoaded(
          config: config,
          localIp: localIp,
          status: syncService.statusNotifier.value,
          clientCount: syncService.clientCountNotifier.value,
        ),
      );
    } catch (e) {
      emit(P2pSyncSettingsError(e.toString()));
    }
  }

  Future<void> saveSettings(P2pSyncConfig config) async {
    final current = state;
    if (current is P2pSyncSettingsLoaded) {
      emit(const P2pSyncSettingsSaving());
      try {
        await syncService.saveConfig(config);
        final localIp = await syncService.getLocalIpAddress() ?? current.localIp;
        emit(
          P2pSyncSettingsLoaded(
            config: config,
            localIp: localIp,
            status: syncService.statusNotifier.value,
            clientCount: syncService.clientCountNotifier.value,
          ),
        );
      } catch (e) {
        emit(P2pSyncSettingsError(e.toString()));
      }
    }
  }

  Future<void> toggleSync(bool isEnabled) async {
    final current = state;
    if (current is P2pSyncSettingsLoaded) {
      final updated = current.config.copyWith(isEnabled: isEnabled);
      await saveSettings(updated);
    }
  }

  Future<void> changeRole(DeviceSyncRole role) async {
    final current = state;
    if (current is P2pSyncSettingsLoaded) {
      final updated = current.config.copyWith(role: role);
      await saveSettings(updated);
    }
  }

  Future<void> triggerReconnection() async {
    await syncService.startSync();
    await loadSettings();
  }
}
