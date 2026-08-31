import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../database/coozy_database.dart';
import '../../../../kitchen_management/presentation/widgets/thermal_kitchen_slip_widget/thermal_kitchen_slip_widget.dart';
import '../../../../core/coozy_core.dart' as core;
import '../../../../shared/coozy_shared.dart' as shared;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _prefKeyFakeData = 'is_fake_data_enabled';

  final ValueNotifier<bool> _isFakeDataEnabledNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _autoPrintKitchenSlipNotifier = ValueNotifier(
    false,
  );
  final ValueNotifier<bool> _enableDetailedItemRemarksNotifier = ValueNotifier(
    true,
  );
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<String> _statusMessageNotifier = ValueNotifier('');

  final ValueNotifier<String?> _activeStageKeyNotifier = ValueNotifier(null);
  final ValueNotifier<Set<String>> _completedStageKeysNotifier = ValueNotifier(
    {},
  );
  final ValueNotifier<int> _currentStepNotifier = ValueNotifier(0);
  final ValueNotifier<int> _totalStepsNotifier = ValueNotifier(7);
  final ValueNotifier<String> _currentStepDescNotifier = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _isFakeDataEnabledNotifier.dispose();
    _autoPrintKitchenSlipNotifier.dispose();
    _enableDetailedItemRemarksNotifier.dispose();
    _isLoadingNotifier.dispose();
    _statusMessageNotifier.dispose();
    _activeStageKeyNotifier.dispose();
    _completedStageKeysNotifier.dispose();
    _currentStepNotifier.dispose();
    _totalStepsNotifier.dispose();
    _currentStepDescNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_prefKeyFakeData) ?? false;
    _isFakeDataEnabledNotifier.value = isEnabled;
    _autoPrintKitchenSlipNotifier.value =
        prefs.getBool(shared.PreferencesKeys.autoPrintKitchenOrderSlip.name) ??
        false;
    _enableDetailedItemRemarksNotifier.value =
        prefs.getBool(shared.PreferencesKeys.enableDetailedItemRemarks.name) ??
        true;

    final database = GetIt.instance<CoozyDatabase>();
    final counts = await FakeDataHelper.getDatasetCounts(database);

    final completed = <String>{};
    for (final entry in counts.entries) {
      if (entry.value > 0) {
        completed.add(entry.key);
      }
    }
    _completedStageKeysNotifier.value = completed;
    _statusMessageNotifier.value = completed.isNotEmpty
        ? 'Fake data active (${completed.length} table datasets populated)'
        : 'Fake data inactive';
  }

  String _tr(BuildContext context, String key, String fallback) {
    return context.tr(key, track: shared.TrackConstants.settingsPageTrack) ??
        fallback;
  }

  Future<void> _onToggleFakeData(bool enable) async {
    if (_isLoadingNotifier.value) return;

    if (enable) {
      _showSelectTablesDialog(context);
      return;
    }

    _isLoadingNotifier.value = true;
    _completedStageKeysNotifier.value = {};
    _activeStageKeyNotifier.value = null;
    _currentStepNotifier.value = 0;

    final database = GetIt.instance<CoozyDatabase>();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    try {
      await core.NotificationApi.init();
      await core.NotificationApi.requestNotificationPermission();
      if (!mounted) return;

      _statusMessageNotifier.value = _tr(
        context,
        shared.LocaleKeys.settingsRemovingFakeData,
        'Removing all fake records...',
      );

      String? lastStageKey;

      await FakeDataHelper.removeFakeData(
        database,
        onProgress: (stageKey, stageDesc, currentStep, totalSteps) {
          core.NotificationApi.showFakeDataProgressNotification(
            currentStep: currentStep,
            totalSteps: totalSteps,
            statusDesc: stageDesc,
          );

          if (!mounted) return;

          if (lastStageKey != null) {
            _completedStageKeysNotifier.value = {
              ..._completedStageKeysNotifier.value,
              lastStageKey!,
            };
          }
          lastStageKey = stageKey;
          _activeStageKeyNotifier.value = stageKey;
          _currentStepDescNotifier.value = stageDesc;
          _currentStepNotifier.value = currentStep;
          _totalStepsNotifier.value = totalSteps;
        },
      );

      if (!mounted) return;

      _activeStageKeyNotifier.value = null;
      _completedStageKeysNotifier.value = {};

      await prefs.setBool(_prefKeyFakeData, false);
      if (!mounted) return;
      _isFakeDataEnabledNotifier.value = false;
      _statusMessageNotifier.value = _tr(
        context,
        shared.LocaleKeys.settingsFakeDataRemoved,
        'All fake records cleanly removed.',
      );

      core.NotificationApi.showFakeDataRemovedNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
                  shared.LocaleKeys.fakeDataSuccessfullyRemovedMsg,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Fake data successfully removed from database.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error processing master fake data: $e\n$stackTrace');
      if (mounted) {
        _statusMessageNotifier.value = 'Error processing fake data: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                    shared.LocaleKeys.commonCustomErrorMsg,
                    track: shared.TrackConstants.commonTrack,
                    params: {"error": e.toString()},
                  ) ??
                  'Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }

  Future<void> _generateSelectedDatasetData(
    List<String> selectedStageKeys,
  ) async {
    if (selectedStageKeys.isEmpty) return;

    _isLoadingNotifier.value = true;
    _completedStageKeysNotifier.value = {};
    _activeStageKeyNotifier.value = null;
    _currentStepNotifier.value = 0;

    final database = GetIt.instance<CoozyDatabase>();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    try {
      await core.NotificationApi.init();
      await core.NotificationApi.requestNotificationPermission();
      if (!mounted) return;

      _statusMessageNotifier.value = _tr(
        context,
        shared.LocaleKeys.settingsGeneratingFakeData,
        'Generating fake records for ${selectedStageKeys.length} selected tables...',
      );

      String? lastStageKey;

      final count = await FakeDataHelper.generateDatasetData(
        database,
        selectedStageKeys,
        onProgress: (stageKey, stageDesc, currentStep, totalSteps) {
          core.NotificationApi.showFakeDataProgressNotification(
            currentStep: currentStep,
            totalSteps: totalSteps,
            statusDesc: stageDesc,
          );

          if (!mounted) return;

          if (lastStageKey != null) {
            _completedStageKeysNotifier.value = {
              ..._completedStageKeysNotifier.value,
              lastStageKey!,
            };
          }
          lastStageKey = stageKey;
          _activeStageKeyNotifier.value = stageKey;
          _currentStepDescNotifier.value = stageDesc;
          _currentStepNotifier.value = currentStep;
          _totalStepsNotifier.value = totalSteps;
        },
      );

      if (!mounted) return;

      if (lastStageKey != null) {
        _completedStageKeysNotifier.value = {
          ..._completedStageKeysNotifier.value,
          lastStageKey!,
        };
      }
      _activeStageKeyNotifier.value = null;

      await prefs.setBool(_prefKeyFakeData, true);
      if (!mounted) return;
      _isFakeDataEnabledNotifier.value = true;
      _statusMessageNotifier.value =
          'Success! $count fake records added for ${selectedStageKeys.length} selected tables.';

      core.NotificationApi.showFakeDataCompletedNotification(count: count);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
                  shared.LocaleKeys.fakedRecordsAddedSuccessfullyMsg,
                  params: {'count': count.toString()},
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Faked records of $count added successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error generating selected dataset: $e\n$stackTrace');
      if (mounted) {
        _statusMessageNotifier.value = 'Error generating fake data: $e';
      }
    } finally {
      if (mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }

  void _showSelectTablesDialog(BuildContext context) {
    final tables = [
      _TableSelectionItem(
        key: 'customers',
        title: 'Customers Table',
        subtitle: '250+ Fake Customers with contact info & phone numbers',
        icon: Icons.people_alt_outlined,
      ),
      _TableSelectionItem(
        key: 'employees',
        title: 'Employees / Staff Table',
        subtitle:
            '100 Staff Profiles (Managers, Chefs, Baristas, Waiters, Cashiers)',
        icon: Icons.badge_outlined,
      ),
      _TableSelectionItem(
        key: 'attendance',
        title: 'Staff Attendance Table',
        subtitle: 'Daily check-in / check-out logs and working durations',
        icon: Icons.co_present_outlined,
      ),
      _TableSelectionItem(
        key: 'leaves',
        title: 'Staff Leaves Table',
        subtitle: '200+ Full-Day & Half-Day leave requests with reasons',
        icon: Icons.event_busy_outlined,
      ),
      _TableSelectionItem(
        key: 'table_info',
        title: 'Dining Tables Table',
        subtitle: '12 Dining Tables with chair capacities & color themes',
        icon: Icons.table_restaurant_outlined,
      ),
      _TableSelectionItem(
        key: 'categories',
        title: 'Menu Categories Table',
        subtitle:
            '7 Main Menu Categories (Beverages, Main Course, Desserts, etc.)',
        icon: Icons.category_outlined,
      ),
      _TableSelectionItem(
        key: 'subcategories',
        title: 'Menu Subcategories Table',
        subtitle: '21 Menu Subcategories linked to main categories',
        icon: Icons.folder_open_outlined,
      ),
      _TableSelectionItem(
        key: 'menu_items',
        title: 'Menu Items & Variations Table',
        subtitle: '28 Menu Items with Portion Variations & Customer Reviews',
        icon: Icons.restaurant_menu_outlined,
      ),
      _TableSelectionItem(
        key: 'recipes',
        title: 'Recipes Table',
        subtitle:
            '8 Gourmet Cafe Recipes with prep time, ingredients & instructions',
        icon: Icons.menu_book_outlined,
      ),
      _TableSelectionItem(
        key: 'inventory',
        title: 'Inventory Raw Stock Table',
        subtitle: '10 Kitchen Raw Material Stock Items with live stock levels',
        icon: Icons.inventory_2_outlined,
      ),
      _TableSelectionItem(
        key: 'purchases',
        title: 'Stock Purchases Table',
        subtitle: '100+ Stock Purchase Receipts & supplier cost records',
        icon: Icons.shopping_cart_outlined,
      ),
      _TableSelectionItem(
        key: 'reservations',
        title: 'Table Reservations & Pre-Orders Table',
        subtitle:
            '215 Table Reservations with Pre-Ordered Items & seat details',
        icon: Icons.event_seat_outlined,
      ),
      _TableSelectionItem(
        key: 'orders',
        title: 'Orders & Kitchen Items Table',
        subtitle:
            '150+ Customer Orders (Dine-In, Takeaway, Delivery, Pre-Orders)',
        icon: Icons.receipt_long_outlined,
      ),
      _TableSelectionItem(
        key: 'invoices',
        title: 'Invoices & Payments Table',
        subtitle:
            '100+ Invoices with 5% GST calculation & Payment Transactions',
        icon: Icons.point_of_sale_outlined,
      ),
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final allSelected = tables.every((t) => t.enabled);
            final selectedCount = tables.where((t) => t.enabled).length;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Colors.amber.shade800,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Tables for Fake Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Enable switches for tables to generate fake data',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$selectedCount of ${tables.length} Selected',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                final newValue = !allSelected;
                                for (final t in tables) {
                                  t.enabled = newValue;
                                }
                              });
                            },
                            icon: Icon(
                              allSelected
                                  ? Icons.deselect_rounded
                                  : Icons.select_all_rounded,
                              size: 16,
                            ),
                            label: Text(
                              allSelected ? 'Deselect All' : 'Select All',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.48,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: tables.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, indent: 48),
                          itemBuilder: (context, index) {
                            final item = tables[index];
                            return SwitchListTile.adaptive(
                              value: item.enabled,
                              activeThumbColor: Colors.amber.shade800,
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              secondary: Icon(
                                item.icon,
                                color: item.enabled
                                    ? Colors.amber.shade900
                                    : Colors.grey,
                                size: 22,
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: item.enabled
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                              subtitle: Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: item.enabled
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade500,
                                ),
                              ),
                              onChanged: (val) {
                                setDialogState(() {
                                  item.enabled = val;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: selectedCount == 0
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          final selectedKeys = tables
                              .where((t) => t.enabled)
                              .map((t) => t.key)
                              .toList();
                          _generateSelectedDatasetData(selectedKeys);
                        },
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text(
                    'Submit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _onToggleDataset(
    List<String> stageKeys,
    bool enable, {
    String? datasetName,
  }) async {
    if (_isLoadingNotifier.value) return;

    final name = datasetName ?? 'Dataset';

    if (!enable) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              _tr(
                context,
                shared.LocaleKeys.settingsRemoveFakeDataTitle,
                'Remove $name Fake Data?',
              ),
            ),
            content: Text(
              'Are you sure you want to remove fake records for $name?\n\n'
              'Note: If other datasets depend on this data, dependent fake records may also be cleaned up.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  _tr(context, shared.LocaleKeys.commonCancel, 'Cancel'),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  _tr(context, shared.LocaleKeys.commonDelete, 'Remove'),
                ),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;
    }

    _isLoadingNotifier.value = true;
    final database = GetIt.instance<CoozyDatabase>();

    try {
      await core.NotificationApi.init();
      await core.NotificationApi.requestNotificationPermission();
      if (!mounted) return;

      if (enable) {
        _statusMessageNotifier.value = 'Generating fake data for $name...';
        final count = await FakeDataHelper.generateDatasetData(
          database,
          stageKeys,
          onProgress: (stageKey, stageDesc, currentStep, totalSteps) {
            core.NotificationApi.showFakeDataProgressNotification(
              currentStep: currentStep,
              totalSteps: totalSteps,
              statusDesc: stageDesc,
            );

            if (!mounted) return;

            _activeStageKeyNotifier.value = stageKey;
            _currentStepDescNotifier.value = stageDesc;
            _currentStepNotifier.value = currentStep;
            _totalStepsNotifier.value = totalSteps;
          },
        );

        if (!mounted) return;

        final newCompleted = Set<String>.from(_completedStageKeysNotifier.value)
          ..addAll(stageKeys);
        _completedStageKeysNotifier.value = newCompleted;
        _isFakeDataEnabledNotifier.value = true;
        _statusMessageNotifier.value = '$name fake data added successfully!';

        core.NotificationApi.showFakeDataCompletedNotification(count: count);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr(
                      shared.LocaleKeys.fakeDataActiveInDatabaseMsg,
                      params: {'name': name},
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    '$name fake data active in database!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _statusMessageNotifier.value = 'Removing fake data for $name...';
        await FakeDataHelper.removeDatasetData(database, stageKeys);
        if (!mounted) return;

        final newCompleted = Set<String>.from(_completedStageKeysNotifier.value)
          ..removeAll(stageKeys);
        _completedStageKeysNotifier.value = newCompleted;
        if (newCompleted.isEmpty) {
          _isFakeDataEnabledNotifier.value = false;
        }
        _statusMessageNotifier.value = '$name fake data removed.';

        core.NotificationApi.showFakeDataRemovedNotification();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr(
                      shared.LocaleKeys.fakeDataRemovedFromDatabaseMsg,
                      params: {'name': name},
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    '$name fake data removed from database.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating $name fake data: $e\n$stackTrace');
      if (mounted) {
        _statusMessageNotifier.value = 'Error updating $name fake data: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr(
                    shared.LocaleKeys.commonCustomErrorMsg,
                    track: shared.TrackConstants.commonTrack,
                    params: {"error": e.toString()},
                  ) ??
                  'Error updating $name fake data: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        _activeStageKeyNotifier.value = null;
        _isLoadingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        appBar: AppBar(
          title: Text(
            _tr(context, shared.LocaleKeys.settingsTitle, 'Settings'),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Theme Section
                Text(
                  _tr(
                    context,
                    shared.LocaleKeys.settingsAppearanceSection,
                    'Appearance',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BlocBuilder<shared.ThemeBloc, shared.ThemeState>(
                      builder: (context, themeState) {
                        final isDark = themeState.themeMode == ThemeMode.dark;
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tr(
                                      context,
                                      shared.LocaleKeys.settingsDarkThemeLabel,
                                      'Dark Theme',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isDark
                                        ? _tr(
                                            context,
                                            shared
                                                .LocaleKeys
                                                .settingsDarkThemeEnabled,
                                            'Dark theme enabled',
                                          )
                                        : _tr(
                                            context,
                                            shared
                                                .LocaleKeys
                                                .settingsDarkThemeDisabled,
                                            'Light theme enabled',
                                          ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: isDark,
                              activeThumbColor: theme.primaryColor,
                              onChanged: (value) {
                                context.read<shared.ThemeBloc>().add(
                                  shared.ThemeToggleRequested(value),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Kitchen & Printing Section
                Text(
                  _tr(
                    context,
                    shared.LocaleKeys.settingsKitchenPrintingSection,
                    'Kitchen & Printing',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.print_rounded,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tr(
                                      context,
                                      shared
                                          .LocaleKeys
                                          .settingsAutoPrintKitchenSlipLabel,
                                      'Auto Print Kitchen Order Slip',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _tr(
                                      context,
                                      shared
                                          .LocaleKeys
                                          .settingsAutoPrintKitchenSlipSubtitle,
                                      'Automatically print kitchen order items slip when a new order is placed',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: _autoPrintKitchenSlipNotifier,
                              builder: (context, autoPrint, child) {
                                return Tooltip(
                                  message: _tr(
                                    context,
                                    shared
                                        .LocaleKeys
                                        .settingsAutoPrintKitchenSlipTooltip,
                                    'Toggle automatic printing of kitchen order slips upon order placement',
                                  ),
                                  child: Switch.adaptive(
                                    value: autoPrint,
                                    activeThumbColor: theme.primaryColor,
                                    onChanged: (value) async {
                                      _autoPrintKitchenSlipNotifier.value =
                                          value;
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool(
                                        shared
                                            .PreferencesKeys
                                            .autoPrintKitchenOrderSlip
                                            .name,
                                        value,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit_note_rounded,
                                color: theme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tr(
                                      context,
                                      shared
                                          .LocaleKeys
                                          .settingsEnableDetailedItemRemarksLabel,
                                      'Detailed Item Remarks',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _tr(
                                      context,
                                      shared
                                          .LocaleKeys
                                          .settingsEnableDetailedItemRemarksSubtitle,
                                      'Enable individual item remark input fields & hashtag suggestions when placing orders',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable:
                                  _enableDetailedItemRemarksNotifier,
                              builder: (context, enabled, child) {
                                return Switch.adaptive(
                                  value: enabled,
                                  activeThumbColor: theme.primaryColor,
                                  onChanged: (value) async {
                                    _enableDetailedItemRemarksNotifier.value =
                                        value;
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool(
                                      shared
                                          .PreferencesKeys
                                          .enableDetailedItemRemarks
                                          .name,
                                      value,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.receipt_long_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _tr(
                                context,
                                shared.LocaleKeys.settingsPreviewThermalSlipBtn,
                                'Preview Thermal Printer Slip (80mm/58mm)',
                              ),
                            ),
                            onPressed: () {
                              ThermalKitchenSlipWidget.showPreviewDialog(
                                context,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Language & Localization Section
                Text(
                  _tr(
                    context,
                    shared.LocaleKeys.settingsLanguageSection,
                    'Language & Localization',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<List<shared.LanguageModel>>(
                      future: shared.LanguageModel.getSupportedLanguages(),
                      builder: (context, snapshot) {
                        final availableLanguages =
                            snapshot.data ??
                            shared.LanguageModel.getLanguages();

                        return BlocBuilder<shared.LocaleCubit, Locale>(
                          builder: (context, currentLocale) {
                            final selectedLanguage = availableLanguages
                                .firstWhere(
                                  (lang) =>
                                      lang.code == currentLocale.languageCode &&
                                      lang.countryCode ==
                                          currentLocale.countryCode,
                                  orElse: () => availableLanguages.firstWhere(
                                    (lang) =>
                                        lang.code == currentLocale.languageCode,
                                    orElse: () => availableLanguages.first,
                                  ),
                                );

                            return Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.language_rounded,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tr(
                                          context,
                                          shared
                                              .LocaleKeys
                                              .settingsAppLanguageLabel,
                                          'App Language',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedLanguage.name ?? 'English',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DropdownButton<shared.LanguageModel>(
                                  value: selectedLanguage,
                                  menuMaxHeight: 400,
                                  underline: const SizedBox.shrink(),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  items: availableLanguages.map((lang) {
                                    return DropdownMenuItem<
                                      shared.LanguageModel
                                    >(
                                      value: lang,
                                      child: Text(
                                        lang.name ?? lang.code ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newLang) {
                                    if (newLang != null) {
                                      context
                                          .read<shared.LocaleCubit>()
                                          .changeLocale(newLang);
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Demo & Testing Section
                Text(
                  _tr(
                    context,
                    shared.LocaleKeys.settingsDemoTestingSection,
                    'Demo & Testing',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoadingNotifier,
                  builder: (context, isLoading, child) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isLoading
                            ? null
                            : () {
                                _showFakeDataBottomSheet(context: context);
                              },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.data_array_rounded,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _tr(
                                            context,
                                            shared
                                                .LocaleKeys
                                                .settingsFakeDataModeLabel,
                                            'Fake / Sample Data Mode',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _tr(
                                            context,
                                            shared
                                                .LocaleKeys
                                                .settingsFakeDataModeSubtitle,
                                            'Generates 1,800+ realistic records spanning 1.5 years back across Customers, Orders, Staff, Inventory, Purchases, & Reservations.',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isLoading)
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  else
                                    ValueListenableBuilder<bool>(
                                      valueListenable:
                                          _isFakeDataEnabledNotifier,
                                      builder: (context, isEnabled, child) {
                                        return Switch.adaptive(
                                          value: isEnabled,
                                          activeThumbColor: Colors.amber,
                                          onChanged: isLoading
                                              ? null
                                              : _onToggleFakeData,
                                        );
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ValueListenableBuilder<String>(
                                valueListenable: _statusMessageNotifier,
                                builder: (context, statusMsg, child) {
                                  if (statusMsg.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      statusMsg,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Live Progress Banner (during fake data generation/removal)
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoadingNotifier,
                  builder: (context, isLoading, child) {
                    if (!isLoading) return const SizedBox.shrink();
                    return ValueListenableBuilder<int>(
                      valueListenable: _currentStepNotifier,
                      builder: (context, currentStep, child) {
                        return ValueListenableBuilder<int>(
                          valueListenable: _totalStepsNotifier,
                          builder: (context, totalSteps, child) {
                            return ValueListenableBuilder<String>(
                              valueListenable: _currentStepDescNotifier,
                              builder: (context, stepDesc, child) {
                                final double progress = totalSteps > 0
                                    ? (currentStep / totalSteps).clamp(0.0, 1.0)
                                    : 0.0;
                                final int percentage = (progress * 100).round();

                                return Card(
                                  color: Colors.amber.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.amber.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.amber,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Processing ($currentStep / $totalSteps)',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.amber.shade900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '$percentage%',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor:
                                                Colors.amber.shade100,
                                            color: Colors.amber.shade700,
                                            minHeight: 6,
                                          ),
                                        ),
                                        if (stepDesc.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            stepDesc,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber.shade900,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // Included Sample Data Sets Header
                Text(
                  _tr(
                    context,
                    shared.LocaleKeys.settingsIncludedDataSetsTitle,
                    'Included Sample Data Sets:',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                _buildDataSetTile(
                  icon: Icons.people_alt_outlined,
                  stageKeys: ['customers'],
                  title: 'Customers Table',
                  subtitle: _tr(
                    context,
                    shared.LocaleKeys.settingsCustomersSetSubtitle,
                    '120+ Fake Customers with names & phone numbers',
                  ),
                ),
                _buildDataSetTile(
                  icon: Icons.badge_outlined,
                  stageKeys: ['employees'],
                  title: 'Employees / Staff Table',
                  subtitle: _tr(
                    context,
                    shared.LocaleKeys.settingsStaffSetSubtitle,
                    '20 Employees, 300+ Attendance & 60+ Leave records',
                  ),
                ),
                _buildDataSetTile(
                  icon: Icons.co_present_outlined,
                  stageKeys: ['attendance'],
                  title: 'Staff Attendance Table',
                  subtitle:
                      'Daily check-in / check-out logs and working durations',
                ),
                _buildDataSetTile(
                  icon: Icons.event_busy_outlined,
                  stageKeys: ['leaves'],
                  title: 'Staff Leaves Table',
                  subtitle:
                      '200+ Full-Day & Half-Day leave requests with reasons',
                ),
                _buildDataSetTile(
                  icon: Icons.table_restaurant_outlined,
                  stageKeys: ['table_info'],
                  title: 'Dining Tables Table',
                  subtitle:
                      '12 Dining Tables with chair capacities & color themes',
                ),
                _buildDataSetTile(
                  icon: Icons.category_outlined,
                  stageKeys: ['categories'],
                  title: 'Menu Categories Table',
                  subtitle:
                      '7 Main Menu Categories (Beverages, Main Course, Desserts, etc.)',
                ),
                _buildDataSetTile(
                  icon: Icons.folder_open_outlined,
                  stageKeys: ['subcategories'],
                  title: 'Menu Subcategories Table',
                  subtitle: '21 Menu Subcategories linked to main categories',
                ),
                _buildDataSetTile(
                  icon: Icons.restaurant_menu_outlined,
                  stageKeys: ['menu_items'],
                  title: 'Menu Items & Variations Table',
                  subtitle:
                      '28 Menu Items with Portion Variations & Customer Reviews',
                ),
                _buildDataSetTile(
                  icon: Icons.menu_book_outlined,
                  stageKeys: ['recipes'],
                  title: 'Recipes Table',
                  subtitle:
                      '8 Gourmet Cafe Recipes with prep time, ingredients & instructions',
                ),
                _buildDataSetTile(
                  icon: Icons.inventory_2_outlined,
                  stageKeys: ['inventory'],
                  title: 'Inventory Raw Stock Table',
                  subtitle: _tr(
                    context,
                    shared.LocaleKeys.settingsInventorySetSubtitle,
                    '20 Inventory Items & 150+ Purchase records',
                  ),
                ),
                _buildDataSetTile(
                  icon: Icons.shopping_cart_outlined,
                  stageKeys: ['purchases'],
                  title: 'Stock Purchases Table',
                  subtitle:
                      '100+ Stock Purchase Receipts & supplier cost records',
                ),
                _buildDataSetTile(
                  icon: Icons.event_seat_outlined,
                  stageKeys: ['reservations'],
                  title: 'Table Reservations Table',
                  subtitle: _tr(
                    context,
                    shared.LocaleKeys.settingsReservationsSetSubtitle,
                    '80+ Booked Table Reservations',
                  ),
                ),
                _buildDataSetTile(
                  icon: Icons.receipt_long_outlined,
                  stageKeys: ['orders'],
                  title: 'Orders & Kitchen Items Table',
                  subtitle: _tr(
                    context,
                    shared.LocaleKeys.settingsOrdersSetSubtitle,
                    '250+ Orders & Invoices (1.5 Years history)',
                  ),
                ),
                _buildDataSetTile(
                  icon: Icons.point_of_sale_outlined,
                  stageKeys: ['invoices'],
                  title: 'Invoices & Payments Table',
                  subtitle:
                      '100+ Invoices with 5% GST calculation & Payment Transactions',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataSetTile({
    required IconData icon,
    required List<String> stageKeys,
    required String title,
    required String subtitle,
  }) {
    return ValueListenableBuilder<String?>(
      valueListenable: _activeStageKeyNotifier,
      builder: (context, activeStageKey, child) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: _completedStageKeysNotifier,
          builder: (context, completedStageKeys, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: _isLoadingNotifier,
              builder: (context, isLoading, child) {
                final bool isInProgress = stageKeys.any(
                  (key) => key == activeStageKey,
                );
                final bool isDone = stageKeys.every(
                  (key) => completedStageKeys.contains(key),
                );

                Widget trailingWidget;
                if (isInProgress) {
                  trailingWidget = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Text(
                          'In Progress',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (isDone) {
                  trailingWidget = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (isLoading) {
                  trailingWidget = Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else {
                  trailingWidget = const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isInProgress
                          ? Colors.blue.shade300
                          : (isDone
                                ? Colors.green.shade200
                                : Colors.grey.shade300),
                      width: 1,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Icon(
                        icon,
                        color: isDone
                            ? Colors.green
                            : (isInProgress ? Colors.blue : Colors.blueAccent),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          trailingWidget,
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                            ),
                            tooltip: _tr(
                              context,
                              shared.LocaleKeys.showDialogTooltip,
                              'Show Dialog',
                            ),

                            onPressed: () {
                              _showFakeDataDialog(
                                context: context,
                                selectedTitle: title,
                                selectedSubtitle: subtitle,
                                selectedIcon: icon,
                                stageKeys: stageKeys,
                              );
                            },
                          ),
                        ],
                      ),
                      childrenPadding: const EdgeInsets.all(16),
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          _getDatasetOverviewText(stageKeys),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isDone
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.info_outline_rounded,
                                  size: 18,
                                  color: isDone
                                      ? Colors.green
                                      : Colors.amber.shade900,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isDone
                                      ? 'Dataset Active'
                                      : 'Dataset Inactive',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDone
                                        ? Colors.green.shade800
                                        : Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: isDone,
                              activeThumbColor: Colors.green,
                              onChanged: isLoading
                                  ? null
                                  : (val) {
                                      _onToggleDataset(
                                        stageKeys,
                                        val,
                                        datasetName: title,
                                      );
                                    },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _getDatasetOverviewText(List<String> stageKeys) {
    final key = stageKeys.first;
    switch (key) {
      case 'customers':
        return 'Generates 250+ fake customers with names, Indian phone numbers (+91), ISO codes, and registration timestamps.';
      case 'employees':
        return 'Generates 100 staff profiles (Managers, Head Chefs, Baristas, Waiters, Cashiers) with contact & salary details.';
      case 'attendance':
        return 'Generates daily attendance logs (Full-Day, Half-Day, Absent) for staff members.';
      case 'leaves':
        return 'Generates 200+ Full-Day & Half-Day staff leave applications with status & leave reasons.';
      case 'table_info':
        return 'Generates 12 Dining Tables with chair numbers and color coding.';
      case 'categories':
        return 'Generates 7 main Menu Categories (Beverages, Main Course, Desserts, Starters, Snacks, Bakery, Breakfast).';
      case 'subcategories':
        return 'Generates 21 Menu Subcategories linked to categories.';
      case 'menu_items':
        return 'Generates 28 Menu Items with Small/Medium/Large Portion Variations & Customer Reviews.';
      case 'recipes':
        return 'Generates 8 Gourmet Cafe Recipes with preparation & cooking times, ingredients, and instructions.';
      case 'inventory':
        return 'Generates 10 Kitchen Raw Stock Items (Espresso Beans, Milk, Flour, Sugar, Cheese) with current stock levels.';
      case 'purchases':
        return 'Generates 100+ Stock Purchase logs with quantities and purchase prices.';
      case 'reservations':
        return 'Generates 215 Table Reservations: 15 Current records for Today and 200 Upcoming records spanning the next day to 2 weeks ahead.';
      case 'orders':
        return 'Generates 150+ Customer Orders with Order Items, status, and order type (Dine-In, Takeaway).';
      case 'invoices':
        return 'Generates 100+ Invoices with 5% GST tax calculation, item breakdowns, and Payment Transactions.';
      default:
        return 'Generates realistic demo records for this database table.';
    }
  }

  void _showFakeDataDialog({
    required BuildContext context,
    String? selectedTitle,
    String? selectedSubtitle,
    IconData? selectedIcon,
    List<String>? stageKeys,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(context);
        final isSpecificDataset = stageKeys != null && stageKeys.isNotEmpty;

        return ValueListenableBuilder<Set<String>>(
          valueListenable: _completedStageKeysNotifier,
          builder: (context, completedKeys, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: _isFakeDataEnabledNotifier,
              builder: (context, isGlobalEnabled, child) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _isLoadingNotifier,
                  builder: (context, isLoading, child) {
                    final bool isActive = isSpecificDataset
                        ? completedKeys.contains(stageKeys.first)
                        : isGlobalEnabled;

                    final titleText =
                        selectedTitle ??
                        _tr(
                          context,
                          shared.LocaleKeys.settingsFakeDataModeLabel,
                          'Fake / Sample Data Mode',
                        );

                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              selectedIcon ?? Icons.data_array_rounded,
                              color: Colors.amber.shade800,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isActive
                                      ? _tr(
                                          context,
                                          shared.LocaleKeys.dialogStatusActive,
                                          'Status: Active',
                                        )
                                      : _tr(
                                          context,
                                          shared
                                              .LocaleKeys
                                              .dialogStatusInactive,
                                          'Status: Inactive',
                                        ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.green.shade800
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedSubtitle ??
                                  'Generates 1,800+ realistic demo records spanning 1.5 years back across all cafe modules.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 14),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.shade50
                                    : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive
                                      ? Colors.green.shade300
                                      : Colors.amber.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isActive
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.info_outline_rounded,
                                    color: isActive
                                        ? Colors.green.shade800
                                        : Colors.amber.shade900,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      isActive
                                          ? _tr(
                                              context,
                                              shared
                                                  .LocaleKeys
                                                  .dialogDemoDataActive,
                                              'Demo data active in database',
                                            )
                                          : _tr(
                                              context,
                                              shared
                                                  .LocaleKeys
                                                  .dialogToggleSwitchToEnable,
                                              'Toggle switch to enable data',
                                            ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? Colors.green.shade900
                                            : Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: isActive,
                                    activeThumbColor: Colors.green,
                                    onChanged: isLoading
                                        ? null
                                        : (val) {
                                            if (isSpecificDataset) {
                                              _onToggleDataset(
                                                stageKeys,
                                                val,
                                                datasetName: selectedTitle,
                                              );
                                            } else {
                                              _onToggleFakeData(val);
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ),

                            if (isLoading) ...[
                              const SizedBox(height: 14),
                              ValueListenableBuilder<int>(
                                valueListenable: _currentStepNotifier,
                                builder: (context, currentStep, child) {
                                  return ValueListenableBuilder<int>(
                                    valueListenable: _totalStepsNotifier,
                                    builder: (context, totalSteps, child) {
                                      return ValueListenableBuilder<String>(
                                        valueListenable:
                                            _currentStepDescNotifier,
                                        builder: (context, stepDesc, child) {
                                          final double progress = totalSteps > 0
                                              ? (currentStep / totalSteps)
                                                    .clamp(0.0, 1.0)
                                              : 0.0;
                                          final int percentage =
                                              (progress * 100).round();

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Progress ($currentStep/$totalSteps)',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$percentage%',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              LinearProgressIndicator(
                                                value: progress,
                                                backgroundColor:
                                                    Colors.blue.shade100,
                                                color: Colors.blue.shade700,
                                              ),
                                              if (stepDesc.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  stepDesc,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.blue.shade900,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            _tr(
                              context,
                              shared.LocaleKeys.commonClose,
                              'Close',
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isActive
                                ? Colors.red.shade600
                                : theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (isSpecificDataset) {
                                    _onToggleDataset(
                                      stageKeys,
                                      !isActive,
                                      datasetName: selectedTitle,
                                    );
                                  } else {
                                    _onToggleFakeData(!isActive);
                                  }
                                },
                          icon: Icon(
                            isActive ? Icons.delete_outline : Icons.add_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isActive
                                ? _tr(
                                    context,
                                    shared.LocaleKeys.removeDataButton,
                                    'Remove Data',
                                  )
                                : _tr(
                                    context,
                                    shared.LocaleKeys.populateDataButton,
                                    'Populate Data',
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showFakeDataBottomSheet({
    required BuildContext context,
    String? selectedTitle,
    String? selectedSubtitle,
    IconData? selectedIcon,
    List<String>? stageKeys,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(context);
        final isSpecificDataset = stageKeys != null && stageKeys.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(sheetContext).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      selectedIcon ?? Icons.data_array_rounded,
                      color: Colors.amber.shade800,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedTitle ??
                              _tr(
                                context,
                                shared.LocaleKeys.settingsFakeDataModeLabel,
                                'Fake / Sample Data Mode',
                              ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedSubtitle ??
                              _tr(
                                context,
                                shared.LocaleKeys.settingsFakeDataModeSubtitle,
                                'Generates realistic demo records spanning 1.5 years back across all cafe modules.',
                              ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const Divider(height: 24),
              ValueListenableBuilder<Set<String>>(
                valueListenable: _completedStageKeysNotifier,
                builder: (context, completedKeys, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _isFakeDataEnabledNotifier,
                    builder: (context, isGlobalEnabled, child) {
                      final bool isActive = isSpecificDataset
                          ? completedKeys.contains(stageKeys.first)
                          : isGlobalEnabled;

                      final titleText = isSpecificDataset
                          ? (isActive
                                ? '${selectedTitle ?? 'Dataset'} Active'
                                : '${selectedTitle ?? 'Dataset'} Inactive')
                          : (isActive
                                ? 'All Sample Data Active'
                                : 'All Sample Data Inactive');

                      final subText = isSpecificDataset
                          ? (isActive
                                ? 'Fake records for ${selectedTitle ?? 'dataset'} are active in database.'
                                : 'Toggle switch ON to generate fake records for ${selectedTitle ?? 'dataset'}.')
                          : (isActive
                                ? '1,800+ realistic demo records active across all modules.'
                                : 'Toggle switch ON to generate 1,800+ demo records.');

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.shade50
                              : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? Colors.green.shade300
                                : Colors.amber.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isActive
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.info_outline_rounded,
                              color: isActive
                                  ? Colors.green.shade800
                                  : Colors.amber.shade900,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titleText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.green.shade900
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isActive
                                          ? Colors.green.shade800
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: _isLoadingNotifier,
                              builder: (context, isLoading, child) {
                                if (isLoading) {
                                  return const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.amber,
                                    ),
                                  );
                                }
                                return Switch.adaptive(
                                  value: isActive,
                                  activeThumbColor: Colors.green,
                                  onChanged: (val) {
                                    if (isSpecificDataset) {
                                      _onToggleDataset(
                                        stageKeys,
                                        val,
                                        datasetName: selectedTitle,
                                      );
                                    } else {
                                      _onToggleFakeData(val);
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _isLoadingNotifier,
                builder: (context, isLoading, child) {
                  if (!isLoading) return const SizedBox.shrink();
                  return ValueListenableBuilder<int>(
                    valueListenable: _currentStepNotifier,
                    builder: (context, currentStep, child) {
                      return ValueListenableBuilder<int>(
                        valueListenable: _totalStepsNotifier,
                        builder: (context, totalSteps, child) {
                          return ValueListenableBuilder<String>(
                            valueListenable: _currentStepDescNotifier,
                            builder: (context, stepDesc, child) {
                              final double progress = totalSteps > 0
                                  ? (currentStep / totalSteps).clamp(0.0, 1.0)
                                  : 0.0;
                              final int percentage = (progress * 100).round();

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Processing Stage ($currentStep / $totalSteps)',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                        Text(
                                          '$percentage%',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.blue.shade100,
                                        color: Colors.blue.shade700,
                                        minHeight: 6,
                                      ),
                                    ),
                                    if (stepDesc.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        stepDesc,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade900,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const Text(
                'Dataset Overview:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const _DatasetDetailRow(
                icon: Icons.people_outline,
                label: '200 Customers with full profiles and phones',
              ),
              const _DatasetDetailRow(
                icon: Icons.badge_outlined,
                label: '200 Staff members, 600 Attendance logs & 300 Leaves',
              ),
              const _DatasetDetailRow(
                icon: Icons.receipt_long_outlined,
                label: '250 Orders & Invoices with itemized sales breakdown',
              ),
              const _DatasetDetailRow(
                icon: Icons.kitchen_outlined,
                label: '20 Active live kitchen orders ready for testing',
              ),
              const _DatasetDetailRow(
                icon: Icons.inventory_2_outlined,
                label: '20 Inventory items & 150 Stock purchase logs',
              ),
              const _DatasetDetailRow(
                icon: Icons.event_seat_outlined,
                label: '80 Booked Table reservations & 12 Dining tables',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.commonClose,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Close',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ValueListenableBuilder<Set<String>>(
                      valueListenable: _completedStageKeysNotifier,
                      builder: (context, completedKeys, child) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _isFakeDataEnabledNotifier,
                          builder: (context, isGlobalEnabled, child) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: _isLoadingNotifier,
                              builder: (context, isLoading, child) {
                                final bool isActive = isSpecificDataset
                                    ? completedKeys.contains(stageKeys.first)
                                    : isGlobalEnabled;

                                return ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isActive
                                        ? Colors.red.shade600
                                        : theme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (isSpecificDataset) {
                                            _onToggleDataset(
                                              stageKeys,
                                              !isActive,
                                              datasetName: selectedTitle,
                                            );
                                          } else {
                                            _onToggleFakeData(!isActive);
                                          }
                                        },
                                  icon: Icon(
                                    isActive
                                        ? Icons.delete_outline
                                        : Icons.add_rounded,
                                  ),
                                  label: Text(
                                    isActive
                                        ? _tr(
                                            context,
                                            shared.LocaleKeys.removeDataButton,
                                            'Remove Data',
                                          )
                                        : _tr(
                                            context,
                                            shared.LocaleKeys.populateDataButton,
                                            'Populate Data',
                                          ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DatasetDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DatasetDetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableSelectionItem {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  bool enabled;

  _TableSelectionItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    bool initialEnabled = true,
  }) : enabled = initialEnabled;
}
