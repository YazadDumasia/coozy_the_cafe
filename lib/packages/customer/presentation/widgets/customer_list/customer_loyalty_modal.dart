import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/customer_loyalty_entity.dart';
import '../../../domain/entities/loyalty_tier_config.dart';
import '../../../domain/usecases/customer_usecases.dart';
import 'add_points_dialog.dart';

class CustomerLoyaltyModal extends StatefulWidget {
  const CustomerLoyaltyModal({super.key, required this.customer});

  final CustomerEntity customer;

  static void show(BuildContext context, CustomerEntity customer) {
    if (shared.ResponsiveLayout.isMobile(context)) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => CustomerLoyaltyModal(customer: customer),
      );
    } else {
      final isDesktop = shared.ResponsiveLayout.isDesktop(context);
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 650 : 540,
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
            ),
            child: SingleChildScrollView(
              child: CustomerLoyaltyModal(customer: customer),
            ),
          ),
        ),
      );
    }
  }

  @override
  State<CustomerLoyaltyModal> createState() => _CustomerLoyaltyModalState();
}

class _CustomerLoyaltyModalState extends State<CustomerLoyaltyModal> {
  // Key to force refresh FutureBuilders after adding points
  final ValueNotifier<int> _refreshKeyNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _refreshKeyNotifier.dispose();
    super.dispose();
  }

  void _refreshData() {
    _refreshKeyNotifier.value++;
  }

  Future<void> _openAddPointsDialog(BuildContext ctx) async {
    final messenger = ScaffoldMessenger.of(ctx);
    final result = await AddPointsDialog.show(ctx, widget.customer);
    if (result == true && mounted) {
      _refreshData();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Loyalty points successfully added!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _changeTierDialog(BuildContext ctx, CustomerLoyaltyEntity loyalty) async {
    final messenger = ScaffoldMessenger.of(ctx);
    final currentTier = loyalty.tier;
    final savedConfigsJson = shared.LocalManager.instance
        .getLocaleKeys(key: shared.PreferencesKeys.loyaltyTierThresholds);
    final tierConfigs = LoyaltyTierConfig.decodeList(savedConfigsJson);

    final textController = TextEditingController();
    final textFocusNode = FocusNode();

    bool isCustom = !tierConfigs
        .any((t) => t.name.toLowerCase() == currentTier.toLowerCase());
    if (isCustom) {
      textController.text = currentTier;
    }
    Color customColor = LoyaltyTierConfig.defaultCustomTierColor;

    final selectedTier = await showDialog<String>(
      context: ctx,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        final scheme = theme.colorScheme;
        String tempSelected = currentTier;

        final formKey = GlobalKey<FormState>();
        String? customErrorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isApplyEnabled = isCustom
                ? textController.text.trim().isNotEmpty
                : tempSelected.trim().isNotEmpty;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.military_tech_rounded, color: scheme.primary),
                  const SizedBox(width: 8),
                  const Text('Set Customer Tier'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a configured tier or enter a custom tier name for ${widget.customer.name ?? "Customer"}:',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...tierConfigs.map((cfg) {
                            final isSelected = !isCustom &&
                                tempSelected.toLowerCase() == cfg.name.toLowerCase();
                            final tierColor = cfg.color;

                            return ChoiceChip(
                              avatar: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: tierColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.star, size: 9, color: Colors.white),
                              ),
                              label: Text(
                                '${cfg.name} (${cfg.minPoints}+ pts)',
                                style: TextStyle(
                                  color: isSelected ? scheme.onPrimary : tierColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: tierColor,
                              onSelected: (selected) {
                                if (selected) {
                                  setDialogState(() {
                                    isCustom = false;
                                    tempSelected = cfg.name;
                                    customErrorText = null;
                                  });
                                }
                              },
                            );
                          }),
                          ChoiceChip(
                            avatar: Icon(
                              Icons.edit_note_rounded,
                              size: 16,
                              color: isCustom ? scheme.onPrimary : scheme.primary,
                            ),
                            label: Text(
                              'Custom',
                              style: TextStyle(
                                color: isCustom ? scheme.onPrimary : scheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: isCustom,
                            selectedColor: scheme.primary,
                            onSelected: (selected) {
                              setDialogState(() {
                                isCustom = true;
                                customErrorText = null;
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (textFocusNode.canRequestFocus) {
                                  textFocusNode.requestFocus();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (isCustom) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: textController,
                          focusNode: textFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Custom Tier Name',
                            hintText: 'e.g. Platinum, Club Member, Royal',
                            errorText: customErrorText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            prefixIcon: const Icon(Icons.star_outline_rounded),
                            suffixIcon: textController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 20),
                                    onPressed: () {
                                      setDialogState(() {
                                        textController.clear();
                                        customErrorText = null;
                                      });
                                    },
                                  )
                                : null,
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val.trim().isNotEmpty) {
                                customErrorText = null;
                              }
                            });
                          },
                          validator: (val) {
                            if (isCustom && (val == null || val.trim().isEmpty)) {
                              return 'Please enter a custom tier name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              'Badge Color: ',
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Wrap(
                              spacing: 6,
                              children: [
                                ...LoyaltyTierConfig.selectableColors.take(5),
                                LoyaltyTierConfig.defaultCustomTierColor,
                              ].map((c) {
                                final isSelected = customColor.toARGB32() == c.toARGB32();
                                return InkWell(
                                  onTap: () {
                                    setDialogState(() => customColor = c);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? scheme.onSurface : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 6),
                            Tooltip(
                              message: 'Pick custom color',
                              child: InkWell(
                                onTap: () async {
                                  Color tempC = customColor;
                                  final hexCtrl = TextEditingController(
                                    text: (customColor.toARGB32() & 0xFFFFFF)
                                        .toRadixString(16)
                                        .padLeft(6, '0')
                                        .toUpperCase(),
                                  );
                                  final picked = await showDialog<Color>(
                                    context: dialogCtx,
                                    builder: (cCtx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Row(
                                        children: [
                                          Icon(Icons.palette_rounded, color: scheme.primary),
                                          const SizedBox(width: 8),
                                          const Text('Select Badge Color'),
                                        ],
                                      ),
                                      content: SizedBox(
                                        width: 320,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ColorPicker(
                                                pickerColor: tempC,
                                                onColorChanged: (newC) => tempC = newC,
                                                enableAlpha: false,
                                                displayThumbColor: true,
                                                pickerAreaHeightPercent: 0.65,
                                                paletteType: PaletteType.hsvWithHue,
                                                hexInputController: hexCtrl,
                                                portraitOnly: true,
                                                labelTypes: const <ColorLabelType>[],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const Text('HEX: #', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: hexCtrl,
                                                      textCapitalization: TextCapitalization.characters,
                                                      decoration: InputDecoration(
                                                        hintText: 'RRGGBB',
                                                        isDense: true,
                                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                      ),
                                                      onChanged: (hex) {
                                                        final parsed = LoyaltyTierConfig.hexToColor(hex);
                                                        tempC = parsed;
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(cCtx).pop(null),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(cCtx).pop(tempC),
                                          child: const Text('Select Color'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (picked != null) {
                                    setDialogState(() => customColor = picked);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: scheme.outline.withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.colorize_rounded,
                                    size: 13,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isApplyEnabled
                      ? () {
                          if (isCustom) {
                            final customVal = textController.text.trim();
                            if (customVal.isEmpty) {
                              setDialogState(() {
                                customErrorText = 'Please enter a custom tier name';
                              });
                              return;
                            }
                            Navigator.of(dialogCtx).pop(customVal);
                          } else {
                            if (tempSelected.trim().isNotEmpty) {
                              Navigator.of(dialogCtx).pop(tempSelected.trim());
                            }
                          }
                        }
                      : null,
                  child: const Text('Apply Tier'),
                ),
              ],
            );
          },
        );
      },
    );

    textController.dispose();
    textFocusNode.dispose();

    if (selectedTier != null && selectedTier != currentTier && mounted) {
      try {
        if (isCustom) {
          // If custom tier name is configured, persist it with its custom color to tierConfigs
          final existing = List<LoyaltyTierConfig>.from(tierConfigs);
          final existingIdx = existing.indexWhere((t) => t.name.toLowerCase() == selectedTier.toLowerCase());
          final newConfig = LoyaltyTierConfig(
            name: selectedTier,
            minPoints: loyalty.pointsBalance,
            colorHex: LoyaltyTierConfig.colorToHex(customColor),
          );
          if (existingIdx != -1) {
            existing[existingIdx] = existing[existingIdx].copyWith(
              colorHex: LoyaltyTierConfig.colorToHex(customColor),
            );
          } else {
            existing.add(newConfig);
            existing.sort((a, b) => a.minPoints.compareTo(b.minPoints));
          }
          await shared.LocalManager.instance.setLocaleKeys(
            key: shared.PreferencesKeys.loyaltyTierThresholds,
            value: LoyaltyTierConfig.encodeList(existing),
          );
        }

        final updateTierUseCase = GetIt.I<UpdateCustomerTierUseCase>();
        await updateTierUseCase(
          customerId: loyalty.customerId,
          tier: selectedTier,
        );
        if (mounted) {
          _refreshData();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Tier updated to $selectedTier!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final errorColor = Theme.of(context).colorScheme.error;
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to update tier: $e'),
              backgroundColor: errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final getLoyaltyUseCase = GetIt.I<GetCustomerLoyaltyUseCase>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                  child: Icon(Icons.stars_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customer.name ?? 'Customer Loyalty',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.customer.phoneNumber ?? 'No Phone',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openAddPointsDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Points'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: _refreshKeyNotifier,
              builder: (context, refreshKey, _) {
                return FutureBuilder<CustomerLoyaltyEntity?>(
                  key: ValueKey('loyalty_$refreshKey'),
                  future: widget.customer.id != null
                      ? getLoyaltyUseCase(widget.customer.id!)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final loyalty =
                        snapshot.data ??
                        CustomerLoyaltyEntity(
                          customerId: widget.customer.id ?? 0,
                          pointsBalance: 0,
                          lifetimePointsEarned: 0,
                          lifetimePointsRedeemed: 0,
                          tier: 'Bronze',
                          totalSpent: 0.0,
                          totalVisits: 0,
                        );

                    final isTiersEnabled = shared.LocalManager.instance.getBoolValue(
                      key: shared.PreferencesKeys.enableLoyaltyTiers,
                    );

                    Color tierColor;
                    IconData tierIcon;
                    if (isTiersEnabled) {
                      final savedConfigsJson = shared.LocalManager.instance
                          .getLocaleKeys(key: shared.PreferencesKeys.loyaltyTierThresholds);
                      final tierConfigs = LoyaltyTierConfig.decodeList(savedConfigsJson);
                      final matchedConfig = tierConfigs.where(
                        (c) => c.name.toLowerCase() == loyalty.tier.toLowerCase(),
                      ).firstOrNull;

                      if (matchedConfig != null) {
                        tierColor = matchedConfig.color;
                        switch (loyalty.tier.toLowerCase()) {
                          case 'vip':
                            tierIcon = Icons.diamond_rounded;
                          case 'gold':
                            tierIcon = Icons.workspace_premium_rounded;
                          case 'silver':
                            tierIcon = Icons.military_tech_rounded;
                          default:
                            tierIcon = Icons.stars_rounded;
                        }
                      } else {
                        switch (loyalty.tier.toLowerCase()) {
                          case 'vip':
                            tierColor = Colors.purple;
                            tierIcon = Icons.diamond_rounded;
                          case 'gold':
                            tierColor = Colors.amber.shade700;
                            tierIcon = Icons.workspace_premium_rounded;
                          case 'silver':
                            tierColor = Colors.blueGrey;
                            tierIcon = Icons.military_tech_rounded;
                          default:
                            tierColor = const Color(0xFFCD7F32); // Bronze
                            tierIcon = Icons.shield_rounded;
                        }
                      }
                    } else {
                      tierColor = scheme.primary;
                      tierIcon = Icons.stars_rounded;
                    }

                    return Column(
                      children: [
                        // ── Tier & Points Card ──────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: theme.brightness == Brightness.dark
                                ? LinearGradient(
                                    colors: [
                                      tierColor.withValues(alpha: 0.35),
                                      tierColor.withValues(alpha: 0.15),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      tierColor.withValues(alpha: 0.2),
                                      tierColor.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: tierColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(tierIcon, color: tierColor, size: 28),
                                  const SizedBox(width: 8),
                                  if (isTiersEnabled) ...[
                                    Text(
                                      '${loyalty.tier} Member',
                                      style: TextStyle(
                                        color: tierColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _changeTierDialog(context, loyalty),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: tierColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: tierColor.withValues(alpha: 0.5),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit, size: 12, color: tierColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Edit Tier',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: tierColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Loyalty Rewards',
                                      style: TextStyle(
                                        color: tierColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  Text(
                                    '${loyalty.pointsBalance} Pts',
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: tierColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Redemption Value: ₹${loyalty.discountValueInRupees.toStringAsFixed(2)} off next bill',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Lifetime Stats ──────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _LoyaltyStatItem(
                                label: 'Lifetime Earned',
                                value: '${loyalty.lifetimePointsEarned} pts',
                                icon: Icons.add_circle_outline_rounded,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _LoyaltyStatItem(
                                label: 'Lifetime Redeemed',
                                value: '${loyalty.lifetimePointsRedeemed} pts',
                                icon: Icons.remove_circle_outline_rounded,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _LoyaltyStatItem(
                                label: 'Total Spent',
                                value:
                                    '₹${loyalty.totalSpent.toStringAsFixed(0)}',
                                icon: Icons.payments_rounded,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _LoyaltyStatItem(
                                label: 'Total Visits',
                                value: '${loyalty.totalVisits}',
                                icon: Icons.store_mall_directory_rounded,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // ── Recent Activity Section ─────────────────────────
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 18,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Recent Activity',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 18),
                              tooltip: 'Refresh',
                              visualDensity: VisualDensity.compact,
                              onPressed: _refreshData,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          key: ValueKey('tx_$refreshKey'),
                          future: widget.customer.id != null
                              ? GetIt.I<GetLoyaltyTransactionsUseCase>()(
                                  widget.customer.id!)
                              : Future.value([]),
                          builder: (context, txSnapshot) {
                            if (txSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              );
                            }
                            final txList = txSnapshot.data ?? [];
                            if (txList.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.03)
                                      : Colors.grey.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'No loyalty transactions yet.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 180),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: txList.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final tx = txList[index];
                                  final isEarned = (tx['transaction_type']
                                          as String?) ==
                                      'EARNED';
                                  final pts =
                                      (tx['points'] as num?)?.toInt() ?? 0;
                                  final date =
                                      (tx['created_date'] as String?) ?? '';
                                  final notes = (tx['notes'] as String?) ??
                                      (isEarned ? 'Earned' : 'Redeemed');

                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: isEarned
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : Colors.orange
                                              .withValues(alpha: 0.15),
                                      child: Icon(
                                        isEarned ? Icons.add : Icons.remove,
                                        size: 14,
                                        color: isEarned
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                    title: Text(
                                      notes,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                    subtitle: Text(
                                      date,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    trailing: Text(
                                      '${isEarned ? '+' : '-'}$pts pts',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isEarned
                                            ? Colors.green
                                            : Colors.orange,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoyaltyStatItem extends StatelessWidget {
  const _LoyaltyStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
