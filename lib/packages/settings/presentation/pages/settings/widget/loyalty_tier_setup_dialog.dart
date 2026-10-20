import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/customer/domain/entities/loyalty_tier_config.dart';

/// Modal dialog presented when enabling Customer Loyalty or when configuring tiers.
/// Allows the cafe owner to decide:
/// 1. Whether to enable Tiers or use flat points.
/// 2. If Tiers are enabled, choose between default prebuilt tiers or custom tiers.
/// 3. For each tier, customize:
///    - Tier Name
///    - Minimum points threshold (e.g., Bronze: 0, Silver: 500, Gold: 1000, VIP: 2000)
///    - Color badge/theme
///    - Default starting tier for new customers
class LoyaltyTierSetupDialog extends StatefulWidget {
  const LoyaltyTierSetupDialog({
    super.key,
    required this.initialTiersEnabled,
    required this.initialTierConfigs,
    required this.initialDefaultTier,
  });

  final bool initialTiersEnabled;
  final List<LoyaltyTierConfig> initialTierConfigs;
  final String initialDefaultTier;

  static const List<Color> selectableColors = [
    Color(0xFFCD7F32), // Bronze
    Color(0xFF607D8B), // Silver / BlueGrey
    Color(0xFFFFA000), // Amber / Gold
    Color(0xFF9C27B0), // Purple / VIP
    Color(0xFF2196F3), // Blue / Sapphire
    Color(0xFF4CAF50), // Green / Emerald
    Color(0xFFE91E63), // Pink / Ruby
    Color(0xFF00BCD4), // Cyan / Diamond
  ];

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required bool initialTiersEnabled,
    List<LoyaltyTierConfig>? initialTierConfigs,
    String? initialDefaultTier,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDesktop = shared.ResponsiveLayout.isDesktop(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 680 : 540,
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.90,
            ),
            child: LoyaltyTierSetupDialog(
              initialTiersEnabled: initialTiersEnabled,
              initialTierConfigs:
                  initialTierConfigs ?? LoyaltyTierConfig.defaultPrebuiltList(),
              initialDefaultTier: initialDefaultTier ?? 'Bronze',
            ),
          ),
        );
      },
    );
  }

  @override
  State<LoyaltyTierSetupDialog> createState() => _LoyaltyTierSetupDialogState();
}

class _LoyaltyTierSetupDialogState extends State<LoyaltyTierSetupDialog> {
  late final ValueNotifier<bool> _enableTiersNotifier;
  late final ValueNotifier<bool> _usePrebuiltNotifier;
  late final ValueNotifier<List<LoyaltyTierConfig>> _tierConfigsNotifier;
  late final ValueNotifier<String> _defaultTierNotifier;

  late final TextEditingController _addTierNameController;
  late final FocusNode _addTierNameFocusNode;
  late final TextEditingController _addTierMinPointsController;
  late final FocusNode _addTierMinPointsFocusNode;
  late final ValueNotifier<Color> _selectedNewColorNotifier;

  @override
  void initState() {
    super.initState();
    _enableTiersNotifier = ValueNotifier<bool>(widget.initialTiersEnabled);

    final isStandardPrebuilt =
        _isMatchingPrebuilt(widget.initialTierConfigs);
    _usePrebuiltNotifier = ValueNotifier<bool>(isStandardPrebuilt);

    _tierConfigsNotifier = ValueNotifier<List<LoyaltyTierConfig>>(
      List<LoyaltyTierConfig>.from(widget.initialTierConfigs),
    );

    _defaultTierNotifier = ValueNotifier<String>(
      widget.initialDefaultTier.isNotEmpty
          ? widget.initialDefaultTier
          : (widget.initialTierConfigs.firstOrNull?.name ?? 'Bronze'),
    );

    _addTierNameController = TextEditingController();
    _addTierNameFocusNode = FocusNode();
    _addTierMinPointsController = TextEditingController(text: '0');
    _addTierMinPointsFocusNode = FocusNode();
    _selectedNewColorNotifier =
        ValueNotifier<Color>(LoyaltyTierSetupDialog.selectableColors.first);
  }

  bool _isMatchingPrebuilt(List<LoyaltyTierConfig> list) {
    final prebuilt = LoyaltyTierConfig.defaultPrebuiltList();
    if (list.length != prebuilt.length) return false;
    for (int i = 0; i < list.length; i++) {
      if (list[i].name.toLowerCase() != prebuilt[i].name.toLowerCase() ||
          list[i].minPoints != prebuilt[i].minPoints) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _enableTiersNotifier.dispose();
    _usePrebuiltNotifier.dispose();
    _tierConfigsNotifier.dispose();
    _defaultTierNotifier.dispose();
    _addTierNameController.dispose();
    _addTierNameFocusNode.dispose();
    _addTierMinPointsController.dispose();
    _addTierMinPointsFocusNode.dispose();
    _selectedNewColorNotifier.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Future<Color?> _openColorPickerDialog(BuildContext context, Color initialColor) async {
    Color tempColor = initialColor;
    final hexController = TextEditingController(
      text: (initialColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase(),
    );

    return showDialog<Color>(
      context: context,
      builder: (dlgCtx) {
        final theme = Theme.of(dlgCtx);
        final scheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.palette_rounded, color: scheme.primary),
              const SizedBox(width: 8),
              const Text('Select Custom Color'),
            ],
          ),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    pickerColor: tempColor,
                    onColorChanged: (newColor) {
                      tempColor = newColor;
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    pickerAreaHeightPercent: 0.65,
                    paletteType: PaletteType.hsvWithHue,
                    hexInputController: hexController,
                    portraitOnly: true,
                    labelTypes: const <ColorLabelType>[],
                  ),
                  const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'HEX: #',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: hexController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'RRGGBB',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (hex) {
                          final parsed = LoyaltyTierConfig.hexToColor(hex);
                          tempColor = parsed;
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
              onPressed: () => Navigator.of(dlgCtx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dlgCtx).pop(tempColor),
              child: const Text('Select Color'),
            ),
          ],
        );
      },
    );
  }

  void _addNewCustomTier() {
    final name = _addTierNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a tier name!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final minPts = int.tryParse(_addTierMinPointsController.text.trim()) ?? 0;
    if (minPts < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum points cannot be negative!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final current = List<LoyaltyTierConfig>.from(_tierConfigsNotifier.value);
    if (current.any((t) => t.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tier "$name" already exists!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newTier = LoyaltyTierConfig(
      name: name,
      minPoints: minPts,
      colorHex: _colorToHex(_selectedNewColorNotifier.value),
    );

    current.add(newTier);
    // Sort by minPoints ascending
    current.sort((a, b) => a.minPoints.compareTo(b.minPoints));

    _tierConfigsNotifier.value = current;
    _addTierNameController.clear();
    _addTierMinPointsController.text = '0';
    _addTierNameFocusNode.requestFocus();
  }

  void _removeTier(String tierName) {
    final current = List<LoyaltyTierConfig>.from(_tierConfigsNotifier.value);
    if (current.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one tier is required!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    current.removeWhere((t) => t.name.toLowerCase() == tierName.toLowerCase());
    _tierConfigsNotifier.value = current;

    if (_defaultTierNotifier.value.toLowerCase() == tierName.toLowerCase()) {
      _defaultTierNotifier.value = current.first.name;
    }
  }

  void _editTierThreshold(LoyaltyTierConfig tier) async {
    final controller = TextEditingController(text: tier.minPoints.toString());
    final focusNode = FocusNode();
    Color selectedColor = tier.color;

    final updated = await showDialog<LoyaltyTierConfig>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (dCtx, setDState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.tune_rounded, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text('Edit ${tier.name} Tier'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Minimum Points Threshold',
                      hintText: 'e.g. 500',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.star_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tier Badge Color:'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: LoyaltyTierSetupDialog.selectableColors.map((color) {
                          final isSelected = selectedColor.toARGB32() == color.toARGB32();
                          return InkWell(
                            onTap: () {
                              setDState(() => selectedColor = color);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? scheme.onSurface : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 8),
                      Builder(builder: (_) {
                        final isPredefined = LoyaltyTierSetupDialog.selectableColors
                            .any((c) => c.toARGB32() == selectedColor.toARGB32());
                        return Tooltip(
                          message: 'Pick custom color',
                          child: InkWell(
                            onTap: () async {
                              final picked = await _openColorPickerDialog(ctx, selectedColor);
                              if (picked != null) {
                                setDState(() => selectedColor = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: !isPredefined ? selectedColor : scheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: !isPredefined
                                      ? scheme.onSurface
                                      : scheme.outline.withValues(alpha: 0.5),
                                  width: 2.5,
                                ),
                              ),
                              child: Icon(
                                Icons.colorize_rounded,
                                size: 16,
                                color: !isPredefined ? Colors.white : scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final pts = int.tryParse(controller.text.trim()) ?? tier.minPoints;
                    Navigator.of(ctx).pop(
                      tier.copyWith(
                        minPoints: pts >= 0 ? pts : 0,
                        colorHex: _colorToHex(selectedColor),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    focusNode.dispose();

    if (updated != null && mounted) {
      final current = List<LoyaltyTierConfig>.from(_tierConfigsNotifier.value);
      final idx = current.indexWhere((t) => t.name.toLowerCase() == tier.name.toLowerCase());
      if (idx != -1) {
        current[idx] = updated;
        current.sort((a, b) => a.minPoints.compareTo(b.minPoints));
        _tierConfigsNotifier.value = current;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.military_tech_rounded, color: scheme.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Loyalty Tiers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Configure tier names, point thresholds, and badge colors',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(null),
                tooltip: 'Close',
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Enable Tiers Switch Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable Customer Tiers',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Categorize customers into status tiers with point ranges and badge colors',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: _enableTiersNotifier,
                          builder: (context, enabled, _) {
                            return Switch.adaptive(
                              value: enabled,
                              activeThumbColor: scheme.primary,
                              onChanged: (val) {
                                _enableTiersNotifier.value = val;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // 2. Tiers options if enabled
                  ValueListenableBuilder<bool>(
                    valueListenable: _enableTiersNotifier,
                    builder: (context, tiersEnabled, _) {
                      if (!tiersEnabled) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: scheme.onSurfaceVariant, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'When tiers are disabled, customer loyalty functions purely on points and discounts without status levels.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Tier Options',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          ValueListenableBuilder<bool>(
                            valueListenable: _usePrebuiltNotifier,
                            builder: (context, usePrebuilt, _) {
                              return RadioGroup<bool>(
                                groupValue: usePrebuilt,
                                onChanged: (val) {
                                  if (val == null) return;
                                  if (val) {
                                    _usePrebuiltNotifier.value = true;
                                    _tierConfigsNotifier.value =
                                        LoyaltyTierConfig.defaultPrebuiltList();
                                    _defaultTierNotifier.value = 'Bronze';
                                  } else {
                                    _usePrebuiltNotifier.value = false;
                                  }
                                },
                                child: Column(
                                  children: [
                                    RadioListTile<bool>(
                                      value: true,
                                      dense: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      title: const Text(
                                        'Use Default Prebuilt Tiers',
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: const Text(
                                          'Bronze (0 pts), Silver (500 pts), Gold (1000 pts), VIP (2000 pts)'),
                                    ),
                                    RadioListTile<bool>(
                                      value: false,
                                      dense: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      title: const Text(
                                        'Create Your Own Custom Tiers',
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: const Text(
                                          'Design customized tier names, points threshold, and badge colors'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          // Custom builder inputs if custom
                          ValueListenableBuilder<bool>(
                            valueListenable: _usePrebuiltNotifier,
                            builder: (context, usePrebuilt, _) {
                              if (usePrebuilt) {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: scheme.outline.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add New Custom Tier',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: TextField(
                                            controller: _addTierNameController,
                                            focusNode: _addTierNameFocusNode,
                                            decoration: InputDecoration(
                                              labelText: 'Tier Name',
                                              hintText: 'e.g. Platinum, Club',
                                              isDense: true,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            textCapitalization: TextCapitalization.words,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: TextField(
                                            controller: _addTierMinPointsController,
                                            focusNode: _addTierMinPointsFocusNode,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Min Points',
                                              hintText: 'e.g. 500',
                                              isDense: true,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text('Color: ', style: theme.textTheme.bodySmall),
                                        const SizedBox(width: 6),
                                        ValueListenableBuilder<Color>(
                                          valueListenable: _selectedNewColorNotifier,
                                          builder: (context, selColor, _) {
                                            final isPredefined = LoyaltyTierSetupDialog.selectableColors
                                                .any((c) => c.toARGB32() == selColor.toARGB32());
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Wrap(
                                                  spacing: 6,
                                                  children: LoyaltyTierSetupDialog.selectableColors.map((color) {
                                                    final isSelected =
                                                        selColor.toARGB32() == color.toARGB32();
                                                    return InkWell(
                                                      onTap: () {
                                                        _selectedNewColorNotifier.value = color;
                                                      },
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration: BoxDecoration(
                                                          color: color,
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: isSelected
                                                                ? scheme.onSurface
                                                                : Colors.transparent,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        child: isSelected
                                                            ? const Icon(Icons.check,
                                                                size: 14, color: Colors.white)
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
                                                      final picked = await _openColorPickerDialog(context, selColor);
                                                      if (picked != null) {
                                                        _selectedNewColorNotifier.value = picked;
                                                      }
                                                    },
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: !isPredefined ? selColor : scheme.surfaceContainerHighest,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: !isPredefined
                                                              ? scheme.onSurface
                                                              : scheme.outline.withValues(alpha: 0.5),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.colorize_rounded,
                                                        size: 13,
                                                        color: !isPredefined ? Colors.white : scheme.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        const Spacer(),
                                        ElevatedButton.icon(
                                          onPressed: _addNewCustomTier,
                                          icon: const Icon(Icons.add, size: 16),
                                          label: const Text('Add Tier'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          // Tier chips with Min Points & Color Badges
                          ValueListenableBuilder<List<LoyaltyTierConfig>>(
                            valueListenable: _tierConfigsNotifier,
                            builder: (context, configs, _) {
                              return ValueListenableBuilder<String>(
                                valueListenable: _defaultTierNotifier,
                                builder: (context, defaultTier, _) {
                                  return ValueListenableBuilder<bool>(
                                    valueListenable: _usePrebuiltNotifier,
                                    builder: (context, usePrebuilt, _) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: configs.map((tierConfig) {
                                              final isDefault = tierConfig.name.toLowerCase() ==
                                                  defaultTier.toLowerCase();
                                              final tierColor = tierConfig.color;

                                              return InkWell(
                                                onTap: () {
                                                  _defaultTierNotifier.value = tierConfig.name;
                                                },
                                                onLongPress: usePrebuilt
                                                    ? null
                                                    : () => _editTierThreshold(tierConfig),
                                                borderRadius: BorderRadius.circular(20),
                                                child: Chip(
                                                  avatar: Container(
                                                    width: 18,
                                                    height: 18,
                                                    decoration: BoxDecoration(
                                                      color: tierColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.stars,
                                                        size: 12, color: Colors.white),
                                                  ),
                                                  label: Text(
                                                    '${tierConfig.name} (${tierConfig.minPoints}+ pts)${isDefault ? ' [Default]' : ''}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isDefault
                                                          ? scheme.onPrimary
                                                          : tierColor,
                                                    ),
                                                  ),
                                                  backgroundColor: isDefault
                                                      ? scheme.primary
                                                      : tierColor.withValues(alpha: 0.12),
                                                  deleteIcon: usePrebuilt
                                                      ? null
                                                      : const Icon(Icons.close, size: 16),
                                                  onDeleted: usePrebuilt
                                                      ? null
                                                      : () => _removeTier(tierConfig.name),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            usePrebuilt
                                                ? 'Click any chip to set it as the default starting tier for new customers.'
                                                : 'Click any chip to mark as Default. Long-press a chip to edit points or color.',
                                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final tiersEnabled = _enableTiersNotifier.value;
                  final configs = _tierConfigsNotifier.value;
                  final defaultTier = _defaultTierNotifier.value.isNotEmpty
                      ? _defaultTierNotifier.value
                      : (configs.firstOrNull?.name ?? 'Bronze');

                  Navigator.of(context).pop({
                    'tiersEnabled': tiersEnabled,
                    'tierConfigs': configs,
                    'tiers': configs.map((e) => e.name).toList(),
                    'defaultTier': defaultTier,
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save & Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
