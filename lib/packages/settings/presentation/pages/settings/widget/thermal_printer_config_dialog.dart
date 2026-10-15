import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../../domain/entities/thermal_printer_config.dart';
import '../../../../domain/services/thermal_printer_service.dart';
import '../cubit/thermal_printer_settings_cubit.dart';

class ThermalPrinterConfigDialog extends StatefulWidget {
  final bool initialIsKitchen;

  const ThermalPrinterConfigDialog({super.key, this.initialIsKitchen = false});

  static Future<void> show(
    BuildContext context, {
    bool initialIsKitchen = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return BlocProvider(
          create: (_) => ThermalPrinterSettingsCubit(
            printerService: ThermalPrinterService.instance,
          )..loadSettings(),
          child: ThermalPrinterConfigDialog(initialIsKitchen: initialIsKitchen),
        );
      },
    );
  }

  @override
  State<ThermalPrinterConfigDialog> createState() =>
      _ThermalPrinterConfigDialogState();
}

class _ThermalPrinterConfigDialogState extends State<ThermalPrinterConfigDialog>
    with SingleTickerProviderStateMixin {
  late TabController _stationTabController;
  late final TextEditingController _customerIpController;
  late final TextEditingController _customerPortController;
  late final FocusNode _customerIpFocusNode;
  late final FocusNode _customerPortFocusNode;

  late final TextEditingController _kitchenIpController;
  late final TextEditingController _kitchenPortController;
  late final FocusNode _kitchenIpFocusNode;
  late final FocusNode _kitchenPortFocusNode;

  final ValueNotifier<bool> _isTestingPrintNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _stationTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIsKitchen ? 1 : 0,
    );
    _customerIpController = TextEditingController();
    _customerPortController = TextEditingController();
    _customerIpFocusNode = FocusNode();
    _customerPortFocusNode = FocusNode();

    _kitchenIpController = TextEditingController();
    _kitchenPortController = TextEditingController();
    _kitchenIpFocusNode = FocusNode();
    _kitchenPortFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _stationTabController.dispose();
    _customerIpController.dispose();
    _customerPortController.dispose();
    _customerIpFocusNode.dispose();
    _customerPortFocusNode.dispose();

    _kitchenIpController.dispose();
    _kitchenPortController.dispose();
    _kitchenIpFocusNode.dispose();
    _kitchenPortFocusNode.dispose();

    _isTestingPrintNotifier.dispose();
    super.dispose();
  }

  void _syncControllersWithState(ThermalPrinterSettingsLoaded state) {
    if (_customerIpController.text.isEmpty) {
      _customerIpController.text = state.customerReceiptConfig.ipAddress;
    }
    if (_customerPortController.text.isEmpty) {
      _customerPortController.text = state.customerReceiptConfig.port
          .toString();
    }
    if (_kitchenIpController.text.isEmpty) {
      _kitchenIpController.text = state.kitchenStationConfig.ipAddress;
    }
    if (_kitchenPortController.text.isEmpty) {
      _kitchenPortController.text = state.kitchenStationConfig.port.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final isMobile = screenSize.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 32,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 620,
          maxHeight: screenSize.height * (isMobile ? 0.92 : 0.85),
        ),
        child:
            BlocConsumer<
              ThermalPrinterSettingsCubit,
              ThermalPrinterSettingsState
            >(
              listener: (context, state) {
                if (state is ThermalPrinterSettingsLoaded) {
                  _syncControllersWithState(state);
                }
              },
              builder: (context, state) {
                if (state is ThermalPrinterSettingsLoading ||
                    state is ThermalPrinterSettingsInitial) {
                  return const SizedBox(
                    height: 280,
                    child: shared.LoadingPage(),
                  );
                }

                if (state is ThermalPrinterSettingsError) {
                  return SizedBox(
                    height: 280,
                    child: shared.ErrorPage(
                      errorMsg: state.message,
                      onPressedRetryButton: () => context
                          .read<ThermalPrinterSettingsCubit>()
                          .loadSettings(),
                    ),
                  );
                }

                final loaded = state as ThermalPrinterSettingsLoaded;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.print_rounded,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.tr(
                                    shared
                                        .LocaleKeys
                                        .settingsThermalPrintersDialogTitle,
                                    track:
                                        shared.TrackConstants.settingsPageTrack,
                                  ) ??
                                  'Thermal Printers Setup',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    // Station Tabs: Customer Receipt vs Kitchen KOT
                    TabBar(
                      controller: _stationTabController,
                      indicatorColor: theme.colorScheme.primary,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      isScrollable: isMobile,
                      tabAlignment: isMobile ? TabAlignment.start : TabAlignment.fill,
                      tabs: [
                        Tab(
                          icon: const Icon(
                            Icons.point_of_sale_rounded,
                            size: 18,
                          ),
                          text:
                              context.tr(
                                shared
                                    .LocaleKeys
                                    .settingsThermalPrintersCustomerTitle,
                                track: shared.TrackConstants.settingsPageTrack,
                              ) ??
                              'Customer Receipt',
                        ),
                        Tab(
                          icon: const Icon(Icons.kitchen_rounded, size: 18),
                          text:
                              context.tr(
                                shared
                                    .LocaleKeys
                                    .settingsThermalPrintersKitchenTitle,
                                track: shared.TrackConstants.settingsPageTrack,
                              ) ??
                              'Kitchen KOT',
                        ),
                      ],
                    ),

                    const Divider(height: 1),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _stationTabController,
                        children: [
                          _buildStationConfigTab(
                            context: context,
                            isKitchen: false,
                            config: loaded.customerReceiptConfig,
                            ipController: _customerIpController,
                            portController: _customerPortController,
                            ipFocusNode: _customerIpFocusNode,
                            portFocusNode: _customerPortFocusNode,
                            loadedState: loaded,
                            isMobile: isMobile,
                          ),
                          _buildStationConfigTab(
                            context: context,
                            isKitchen: true,
                            config: loaded.kitchenStationConfig,
                            ipController: _kitchenIpController,
                            portController: _kitchenPortController,
                            ipFocusNode: _kitchenIpFocusNode,
                            portFocusNode: _kitchenPortFocusNode,
                            loadedState: loaded,
                            isMobile: isMobile,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _buildStationConfigTab({
    required BuildContext context,
    required bool isKitchen,
    required ThermalPrinterConfig config,
    required TextEditingController ipController,
    required TextEditingController portController,
    required FocusNode ipFocusNode,
    required FocusNode portFocusNode,
    required ThermalPrinterSettingsLoaded loadedState,
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final cubit = context.read<ThermalPrinterSettingsCubit>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Mode Selector Header
          Text(
            'Connection Type',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Responsive Connection Mode Selector
          _buildConnectionTypeSelector(
            context: context,
            config: config,
            isKitchen: isKitchen,
            cubit: cubit,
            isMobile: isMobile,
          ),

          const SizedBox(height: 16),

          // Paper Size Choice Header
          Text(
            'Thermal Roll Paper Width',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Responsive Paper Size Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('80 mm (Standard Cafe / KOT)'),
                selected: config.paperSize == ThermalPaperSize.mm80,
                onSelected: (val) {
                  if (val) {
                    final updated = config.copyWith(
                      paperSize: ThermalPaperSize.mm80,
                    );
                    isKitchen
                        ? cubit.updateKitchenConfig(updated)
                        : cubit.updateCustomerConfig(updated);
                  }
                },
              ),
              ChoiceChip(
                label: const Text('58 mm (Compact Portable)'),
                selected: config.paperSize == ThermalPaperSize.mm58,
                onSelected: (val) {
                  if (val) {
                    final updated = config.copyWith(
                      paperSize: ThermalPaperSize.mm58,
                    );
                    isKitchen
                        ? cubit.updateKitchenConfig(updated)
                        : cubit.updateCustomerConfig(updated);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),

          // Type specific inputs
          if (config.type == ThermalPrinterType.network) ...[
            Text(
              'Network Printer Settings (Raw Port 9100)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (isMobile) ...[
              TextFormField(
                controller: ipController,
                focusNode: ipFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Printer IP Address',
                  hintText: 'e.g. 192.168.1.200',
                  prefixIcon: Icon(Icons.lan_outlined),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (val) {
                  final updated = config.copyWith(ipAddress: val.trim());
                  isKitchen
                      ? cubit.updateKitchenConfig(updated)
                      : cubit.updateCustomerConfig(updated);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: portController,
                focusNode: portFocusNode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: '9100',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (val) {
                  final port = int.tryParse(val.trim()) ?? 9100;
                  final updated = config.copyWith(port: port);
                  isKitchen
                      ? cubit.updateKitchenConfig(updated)
                      : cubit.updateCustomerConfig(updated);
                },
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: ipController,
                      focusNode: ipFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Printer IP Address',
                        hintText: 'e.g. 192.168.1.200',
                        prefixIcon: Icon(Icons.lan_outlined),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final updated = config.copyWith(ipAddress: val.trim());
                        isKitchen
                            ? cubit.updateKitchenConfig(updated)
                            : cubit.updateCustomerConfig(updated);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: portController,
                      focusNode: portFocusNode,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        hintText: '9100',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final port = int.tryParse(val.trim()) ?? 9100;
                        final updated = config.copyWith(port: port);
                        isKitchen
                            ? cubit.updateKitchenConfig(updated)
                            : cubit.updateCustomerConfig(updated);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ] else if (config.type == ThermalPrinterType.bluetooth) ...[
            _buildBluetoothSection(
              context: context,
              theme: theme,
              config: config,
              loadedState: loadedState,
              cubit: cubit,
              isKitchen: isKitchen,
            ),
          ] else if (config.type == ThermalPrinterType.usb) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Connected USB Thermal Printers',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: loadedState.isScanningUsb
                      ? null
                      : () => cubit.refreshUsbDevices(),
                  icon: loadedState.isScanningUsb
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (loadedState.usbPrinters.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.usb_off_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No USB thermal printer detected. Please connect your printer via USB cable or OTG adapter.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: config.usbVendorId.isNotEmpty
                    ? '${config.usbVendorId}_${config.usbProductId}'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Select USB Thermal Printer',
                  prefixIcon: Icon(Icons.usb_rounded),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                isExpanded: true,
                items: loadedState.usbPrinters.map((dev) {
                  final key = '${dev.vendorId}_${dev.productId}';
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(
                      '${dev.name ?? "USB Printer"} (VID:${dev.vendorId})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (selectedKey) {
                  if (selectedKey != null) {
                    final matched = loadedState.usbPrinters.firstWhere(
                      (d) => '${d.vendorId}_${d.productId}' == selectedKey,
                    );
                    final updated = config.copyWith(
                      usbName: matched.name ?? 'USB Thermal Printer',
                      usbVendorId: matched.vendorId ?? '',
                      usbProductId: matched.productId ?? '',
                    );
                    isKitchen
                        ? cubit.updateKitchenConfig(updated)
                        : cubit.updateCustomerConfig(updated);
                  }
                },
              ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Universal System Spooler mode renders the thermal receipt/KOT slip as a native print job, letting you pick any installed system printer or PDF exporter.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Test Print Action Button
          ValueListenableBuilder<bool>(
            valueListenable: _isTestingPrintNotifier,
            builder: (context, isTesting, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isTesting
                      ? null
                      : () async {
                          _isTestingPrintNotifier.value = true;
                          try {
                            final success = await cubit.sendTestPrint(
                              isKitchenStation: isKitchen,
                            );
                            if (!context.mounted) return;
                            if (success) {
                              shared.SnackBarUtils.showSuccess(
                                context,
                                message:
                                    'Test print sent successfully to ${isKitchen ? "Kitchen" : "Customer"} Station!',
                              );
                            } else {
                              shared.SnackBarUtils.showError(
                                context,
                                message:
                                    'Failed to send test print. Please check network/Bluetooth connection.',
                              );
                            }
                          } finally {
                            _isTestingPrintNotifier.value = false;
                          }
                        },
                  icon: isTesting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.print_rounded),
                  label: Text(
                    isTesting
                        ? 'Sending Test Print...'
                        : 'Send Test Print to ${isKitchen ? "Kitchen" : "Receipt"} Printer',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionTypeSelector({
    required BuildContext context,
    required ThermalPrinterConfig config,
    required bool isKitchen,
    required ThermalPrinterSettingsCubit cubit,
    required bool isMobile,
  }) {
    if (isMobile) {
      // Clean Wrap with ChoiceChips for mobile to prevent overflow & vertical text
      final types = [
        (ThermalPrinterType.network, 'Network', Icons.wifi_rounded),
        (ThermalPrinterType.bluetooth, 'Bluetooth', Icons.bluetooth_rounded),
        (ThermalPrinterType.usb, 'USB', Icons.usb_rounded),
        (ThermalPrinterType.systemSpooler, 'Spooler', Icons.picture_as_pdf_rounded),
      ];

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: types.map((item) {
          final isSelected = config.type == item.$1;
          return ChoiceChip(
            avatar: Icon(item.$3, size: 16),
            label: Text(item.$2),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                final updated = config.copyWith(type: item.$1);
                isKitchen
                    ? cubit.updateKitchenConfig(updated)
                    : cubit.updateCustomerConfig(updated);
              }
            },
          );
        }).toList(),
      );
    }

    return SegmentedButton<ThermalPrinterType>(
      segments: const [
        ButtonSegment(
          value: ThermalPrinterType.network,
          icon: Icon(Icons.wifi_rounded, size: 18),
          label: Text('Network'),
        ),
        ButtonSegment(
          value: ThermalPrinterType.bluetooth,
          icon: Icon(Icons.bluetooth_rounded, size: 18),
          label: Text('Bluetooth'),
        ),
        ButtonSegment(
          value: ThermalPrinterType.usb,
          icon: Icon(Icons.usb_rounded, size: 18),
          label: Text('USB'),
        ),
        ButtonSegment(
          value: ThermalPrinterType.systemSpooler,
          icon: Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: Text('Spooler'),
        ),
      ],
      selected: {config.type},
      onSelectionChanged: (selected) {
        if (selected.isNotEmpty) {
          final updated = config.copyWith(type: selected.first);
          isKitchen
              ? cubit.updateKitchenConfig(updated)
              : cubit.updateCustomerConfig(updated);
        }
      },
    );
  }

  Widget _buildBluetoothSection({
    required BuildContext context,
    required ThemeData theme,
    required ThermalPrinterConfig config,
    required ThermalPrinterSettingsLoaded loadedState,
    required ThermalPrinterSettingsCubit cubit,
    required bool isKitchen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Paired Bluetooth Printers',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: loadedState.isScanningBluetooth
                  ? null
                  : () => cubit.refreshBluetoothDevices(),
              icon: loadedState.isScanningBluetooth
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Bluetooth status alerts
        if (!loadedState.isBluetoothEnabled)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bluetooth_disabled,
                  color: theme.colorScheme.onErrorContainer,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bluetooth is currently turned OFF. Please turn on Bluetooth in your phone settings.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (!loadedState.isBluetoothPermissionGranted)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security_update_warning,
                  color: theme.colorScheme.onTertiaryContainer,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bluetooth permission is needed to scan nearby printers.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => cubit.requestBluetoothPermission(),
                  child: const Text('Grant'),
                ),
              ],
            ),
          ),

        if (loadedState.pairedBluetoothDevices.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No paired thermal printers detected.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '1. Open Android Phone Settings > Bluetooth.\n'
                  '2. Turn ON your thermal printer and pair with it (default PIN is usually 0000 or 1234).\n'
                  '3. Return here and tap "Refresh".',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: config.bluetoothAddress.isNotEmpty
                ? config.bluetoothAddress
                : null,
            decoration: const InputDecoration(
              labelText: 'Select Paired Printer',
              prefixIcon: Icon(Icons.bluetooth_connected),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            isExpanded: true,
            items: loadedState.pairedBluetoothDevices.map((dev) {
              return DropdownMenuItem<String>(
                value: dev.macAdress,
                child: Text(
                  '${dev.name} (${dev.macAdress})',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (selectedMac) {
              if (selectedMac != null) {
                final matched = loadedState.pairedBluetoothDevices
                    .firstWhere((d) => d.macAdress == selectedMac);
                final updated = config.copyWith(
                  bluetoothAddress: selectedMac,
                  bluetoothName: matched.name,
                );
                isKitchen
                    ? cubit.updateKitchenConfig(updated)
                    : cubit.updateCustomerConfig(updated);
              }
            },
          ),
      ],
    );
  }
}
