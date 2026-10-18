import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../../domain/entities/p2p_sync_config.dart';
import '../../../../domain/services/local_p2p_sync_service.dart';
import '../cubit/p2p_sync_settings_cubit.dart';

class LocalP2pSyncConfigDialog extends StatefulWidget {
  const LocalP2pSyncConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return BlocProvider(
          create: (_) => P2pSyncSettingsCubit(
            syncService: LocalP2pSyncService.instance,
          )..loadSettings(),
          child: Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: shared.ResponsiveLayout.isMobile(dialogContext) ? 12 : 24,
              vertical: shared.ResponsiveLayout.isMobile(dialogContext) ? 16 : 32,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 700 : (isTablet ? 600 : double.infinity),
                maxHeight: MediaQuery.sizeOf(dialogContext).height *
                    (shared.ResponsiveLayout.isMobile(dialogContext) ? 0.92 : 0.85),
              ),
              child: const LocalP2pSyncConfigDialog(),
            ),
          ),
        );
      },
    );
  }

  @override
  State<LocalP2pSyncConfigDialog> createState() =>
      _LocalP2pSyncConfigDialogState();
}

class _LocalP2pSyncConfigDialogState extends State<LocalP2pSyncConfigDialog> {
  late final TextEditingController _deviceNameController;
  late final TextEditingController _hubIpController;
  late final TextEditingController _hubPortController;

  late final FocusNode _deviceNameFocus;
  late final FocusNode _hubIpFocus;
  late final FocusNode _hubPortFocus;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final config = LocalP2pSyncService.instance.currentConfig;
    _deviceNameController = TextEditingController(text: config.deviceName);
    _hubIpController = TextEditingController(text: config.hubIpAddress);
    _hubPortController = TextEditingController(text: config.hubPort.toString());

    _deviceNameFocus = FocusNode();
    _hubIpFocus = FocusNode();
    _hubPortFocus = FocusNode();
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _hubIpController.dispose();
    _hubPortController.dispose();

    _deviceNameFocus.dispose();
    _hubIpFocus.dispose();
    _hubPortFocus.dispose();
    super.dispose();
  }

  String _tr(BuildContext context, String key, String fallback) {
    return context.tr(key, track: shared.TrackConstants.settingsPageTrack) ??
        fallback;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return BlocConsumer<P2pSyncSettingsCubit, P2pSyncSettingsState>(
      listener: (context, state) {
        if (state is P2pSyncSettingsLoaded) {
          if (_deviceNameController.text != state.config.deviceName) {
            _deviceNameController.text = state.config.deviceName;
          }
          if (_hubIpController.text != state.config.hubIpAddress) {
            _hubIpController.text = state.config.hubIpAddress;
          }
          if (_hubPortController.text != state.config.hubPort.toString()) {
            _hubPortController.text = state.config.hubPort.toString();
          }
        }
      },
      builder: (context, state) {
        if (state is P2pSyncSettingsLoading) {
          return const SizedBox(
            height: 280,
            child: shared.LoadingPage(),
          );
        }

        if (state is P2pSyncSettingsError) {
          return SizedBox(
            height: 280,
            child: shared.ErrorPage(
              errorMsg: state.message,
              onPressedRetryButton: () =>
                  context.read<P2pSyncSettingsCubit>().loadSettings(),
            ),
          );
        }

        final config = state is P2pSyncSettingsLoaded
            ? state.config
            : LocalP2pSyncService.instance.currentConfig;
        final localIp = state is P2pSyncSettingsLoaded ? state.localIp : '';
        final status = state is P2pSyncSettingsLoaded
            ? state.status
            : LocalP2pSyncService.instance.statusNotifier.value;
        final clientCount = state is P2pSyncSettingsLoaded
            ? state.clientCount
            : LocalP2pSyncService.instance.clientCountNotifier.value;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Icon(Icons.wifi_tethering_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tr(
                      context,
                      shared.LocaleKeys.settingsLocalP2pSyncDialogTitle,
                      'Local Wi-Fi Peer-to-Peer Sync',
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Live Connection Status Card
                  _buildLiveStatusCard(context, config, localIp, status, clientCount),
                  const SizedBox(height: 16),

                  // 2. Enable/Disable Master Switch
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                    child: SwitchListTile.adaptive(
                      title: Text(
                        _tr(
                          context,
                          shared.LocaleKeys.settingsLocalP2pSyncEnableLabel,
                          'Enable Offline Wi-Fi Sync',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _tr(
                          context,
                          shared.LocaleKeys.settingsLocalP2pSyncEnableSubtitle,
                          'Sync orders between POS and Tablets without cloud/backend',
                        ),
                      ),
                      value: config.isEnabled,
                      onChanged: (val) {
                        context.read<P2pSyncSettingsCubit>().toggleSync(val);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Station Role Selector
                  Text(
                    _tr(
                      context,
                      shared.LocaleKeys.settingsLocalP2pSyncRoleSection,
                      'Device Terminal Role',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildRoleSelector(context, config),
                  const SizedBox(height: 16),

                  // 4. Device Name Field
                  TextFormField(
                    controller: _deviceNameController,
                    focusNode: _deviceNameFocus,
                    decoration: InputDecoration(
                      labelText: _tr(
                        context,
                        shared.LocaleKeys.settingsLocalP2pSyncTerminalName,
                        'Terminal Name',
                      ),
                      hintText: _tr(
                        context,
                        shared.LocaleKeys.settingsLocalP2pSyncTerminalHint,
                        'e.g., Main POS Counter, Waiter Tab 1, Kitchen KDS',
                      ),
                      prefixIcon: const Icon(Icons.devices_other_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // 5. Role-Specific Configuration (Hub Info or Client Connection)
                  if (config.role == DeviceSyncRole.posHub)
                    _buildHubDetailsCard(context, localIp, config)
                  else if (config.role == DeviceSyncRole.clientTerminal)
                    _buildClientDetailsCard(context, config),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        _tr(
                          context,
                          shared.LocaleKeys.settingsLocalP2pSyncRestartBtn,
                          'Restart Connection',
                        ),
                      ),
                      onPressed: () {
                        context.read<P2pSyncSettingsCubit>().triggerReconnection();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        _tr(
                          context,
                          shared.LocaleKeys.settingsLocalP2pSyncSaveBtn,
                          'Save & Apply',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final updated = config.copyWith(
                            deviceName: _deviceNameController.text.trim(),
                            hubIpAddress: _hubIpController.text.trim(),
                            hubPort: int.tryParse(_hubPortController.text.trim()) ?? 8899,
                          );
                          context.read<P2pSyncSettingsCubit>().saveSettings(updated);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveStatusCard(
    BuildContext context,
    P2pSyncConfig config,
    String localIp,
    SyncConnectionStatus status,
    int clientCount,
  ) {
    final scheme = Theme.of(context).colorScheme;

    Color statusColor;
    String statusTitle;
    IconData statusIcon;

    switch (status) {
      case SyncConnectionStatus.hosting:
        statusColor = Colors.green;
        final hostingTpl = _tr(
          context,
          shared.LocaleKeys.settingsLocalP2pSyncStatusHosting,
          'POS Hub Active — Hosting ($clientCount clients)',
        );
        statusTitle = hostingTpl.replaceAll(r'${count}', clientCount.toString());
        statusIcon = Icons.cloud_done_rounded;
        break;
      case SyncConnectionStatus.connected:
        statusColor = Colors.green;
        statusTitle = _tr(
          context,
          shared.LocaleKeys.settingsLocalP2pSyncStatusConnected,
          'Connected to POS Hub',
        );
        statusIcon = Icons.wifi_protected_setup_rounded;
        break;
      case SyncConnectionStatus.discovering:
        statusColor = Colors.orange;
        statusTitle = _tr(
          context,
          shared.LocaleKeys.settingsLocalP2pSyncStatusDiscovering,
          'Searching for POS Hub via mDNS/UDP...',
        );
        statusIcon = Icons.radar_rounded;
        break;
      case SyncConnectionStatus.connecting:
        statusColor = Colors.blue;
        statusTitle = _tr(
          context,
          shared.LocaleKeys.settingsLocalP2pSyncStatusConnecting,
          'Connecting to POS Hub...',
        );
        statusIcon = Icons.sync_rounded;
        break;
      case SyncConnectionStatus.error:
        statusColor = scheme.error;
        statusTitle = _tr(
          context,
          shared.LocaleKeys.settingsLocalP2pSyncStatusError,
          'Sync Connection Error',
        );
        statusIcon = Icons.error_outline_rounded;
        break;
      default:
        statusColor = scheme.outline;
        statusTitle = config.isEnabled
            ? _tr(
                context,
                shared.LocaleKeys.settingsLocalP2pSyncStatusIdle,
                'Idle',
              )
            : _tr(
                context,
                shared.LocaleKeys.settingsLocalP2pSyncStatusDisabled,
                'Offline Sync Disabled',
              );
        statusIcon = Icons.wifi_off_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor,
            radius: 18,
            child: Icon(statusIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  localIp.isNotEmpty
                      ? 'Local Wi-Fi IP: $localIp (Port: ${config.hubPort})'
                      : 'Connecting to local Wi-Fi...',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(BuildContext context, P2pSyncConfig config) {
    return Row(
      children: [
        Expanded(
          child: _roleCard(
            context: context,
            title: _tr(
              context,
              shared.LocaleKeys.settingsLocalP2pSyncHubTitle,
              'POS Hub (Master)',
            ),
            desc: _tr(
              context,
              shared.LocaleKeys.settingsLocalP2pSyncHubDesc,
              'Central Billing counter hosting WebSocket server',
            ),
            icon: Icons.hub_rounded,
            isSelected: config.role == DeviceSyncRole.posHub,
            onTap: () {
              context.read<P2pSyncSettingsCubit>().changeRole(DeviceSyncRole.posHub);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _roleCard(
            context: context,
            title: _tr(
              context,
              shared.LocaleKeys.settingsLocalP2pSyncClientTitle,
              'Waiter / KDS (Client)',
            ),
            desc: _tr(
              context,
              shared.LocaleKeys.settingsLocalP2pSyncClientDesc,
              'Tablets pushing and receiving order updates',
            ),
            icon: Icons.tablet_mac_rounded,
            isSelected: config.role == DeviceSyncRole.clientTerminal,
            onTap: () {
              context.read<P2pSyncSettingsCubit>().changeRole(DeviceSyncRole.clientTerminal);
            },
          ),
        ),
      ],
    );
  }

  Widget _roleCard({
    required BuildContext context,
    required String title,
    required String desc,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? scheme.primary.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? scheme.primary : scheme.onSurfaceVariant),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: scheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildHubDetailsCard(
    BuildContext context,
    String localIp,
    P2pSyncConfig config,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hubConnectPayload = 'COOZY_CONNECT:$localIp:${config.hubPort}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2_rounded, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  _tr(
                    context,
                    shared.LocaleKeys.settingsLocalP2pSyncQrTitle,
                    'Client Pairing QR Code',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _tr(
                context,
                shared.LocaleKeys.settingsLocalP2pSyncQrDesc,
                'Other tablets on this Wi-Fi can scan this code or use UDP auto-discovery to sync instantly.',
              ),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? scheme.surfaceContainerHighest : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 170,
                  height: 170,
                  child: SfBarcodeGenerator(
                    value: hubConnectPayload,
                    symbology: QRCode(),
                    barColor: isDark ? scheme.onSurface : Colors.black,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'POS Endpoint: ws://$localIp:${config.hubPort}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDetailsCard(BuildContext context, P2pSyncConfig config) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _tr(
                  context,
                  shared.LocaleKeys.settingsLocalP2pSyncAutoDiscoverLabel,
                  'Auto-Discover POS Hub (UDP Broadcast)',
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _tr(
                  context,
                  shared.LocaleKeys.settingsLocalP2pSyncAutoDiscoverSubtitle,
                  'Automatically find the POS Hub on the local Wi-Fi subnet',
                ),
                style: const TextStyle(fontSize: 12),
              ),
              value: config.autoDiscover,
              onChanged: (val) {
                final updated = config.copyWith(autoDiscover: val);
                context.read<P2pSyncSettingsCubit>().saveSettings(updated);
              },
            ),
            if (!config.autoDiscover) ...[
              const Divider(height: 24),
              Text(
                _tr(
                  context,
                  shared.LocaleKeys.settingsLocalP2pSyncHubIpLabel,
                  'Manual POS Hub Endpoint',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _hubIpController,
                      focusNode: _hubIpFocus,
                      decoration: InputDecoration(
                        labelText: _tr(
                          context,
                          shared.LocaleKeys.settingsLocalP2pSyncHubIpLabel,
                          'POS Hub IP',
                        ),
                        hintText: '192.168.1.100',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _hubPortController,
                      focusNode: _hubPortFocus,
                      decoration: InputDecoration(
                        labelText: _tr(
                          context,
                          shared.LocaleKeys.settingsLocalP2pSyncPortLabel,
                          'Port',
                        ),
                        hintText: '8899',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
