import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class ReservationFilterCriteria {
  final int? status;
  final int? minGuests;
  final String dateFilter; // 'all', 'today', 'tomorrow', 'this_week'

  const ReservationFilterCriteria({
    this.status,
    this.minGuests,
    this.dateFilter = 'all',
  });

  bool get isActive =>
      status != null || minGuests != null || dateFilter != 'all';

  ReservationFilterCriteria copyWith({
    int? Function()? status,
    int? Function()? minGuests,
    String? dateFilter,
  }) {
    return ReservationFilterCriteria(
      status: status != null ? status() : this.status,
      minGuests: minGuests != null ? minGuests() : this.minGuests,
      dateFilter: dateFilter ?? this.dateFilter,
    );
  }
}

class ReservationFilterBottomSheet extends StatefulWidget {
  final ReservationFilterCriteria initialCriteria;
  final ValueChanged<ReservationFilterCriteria> onApply;

  const ReservationFilterBottomSheet({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  @override
  State<ReservationFilterBottomSheet> createState() =>
      _ReservationFilterBottomSheetState();
}

class _ReservationFilterBottomSheetState
    extends State<ReservationFilterBottomSheet> {
  late ValueNotifier<ReservationFilterCriteria> _criteriaNotifier;

  @override
  void initState() {
    super.initState();
    _criteriaNotifier = ValueNotifier<ReservationFilterCriteria>(
      widget.initialCriteria,
    );
  }

  @override
  void dispose() {
    _criteriaNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ValueListenableBuilder<ReservationFilterCriteria>(
        valueListenable: _criteriaNotifier,
        builder: (context, criteria, _) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filter Reservations',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (criteria.isActive)
                      TextButton.icon(
                        onPressed: () {
                          _criteriaNotifier.value =
                              const ReservationFilterCriteria();
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text(
                          context.tr(
                                shared.LocaleKeys.commonReset,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Reset All',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Status Filter
                Text(
                  'Reservation Status',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildChoiceChip(
                      label: 'All Statuses',
                      isSelected: criteria.status == null,
                      onSelected: (selected) {
                        if (selected) {
                          _criteriaNotifier.value = criteria.copyWith(
                            status: () => null,
                          );
                        }
                      },
                    ),
                    _buildChoiceChip(
                      label: 'Pending',
                      isSelected: criteria.status == 0,
                      onSelected: (selected) {
                        _criteriaNotifier.value = criteria.copyWith(
                          status: () => selected ? 0 : null,
                        );
                      },
                    ),
                    _buildChoiceChip(
                      label: 'Confirmed',
                      isSelected: criteria.status == 1,
                      onSelected: (selected) {
                        _criteriaNotifier.value = criteria.copyWith(
                          status: () => selected ? 1 : null,
                        );
                      },
                    ),
                    _buildChoiceChip(
                      label: 'Seated',
                      isSelected: criteria.status == 2,
                      onSelected: (selected) {
                        _criteriaNotifier.value = criteria.copyWith(
                          status: () => selected ? 2 : null,
                        );
                      },
                    ),
                    _buildChoiceChip(
                      label: 'Completed',
                      isSelected: criteria.status == 3,
                      onSelected: (selected) {
                        _criteriaNotifier.value = criteria.copyWith(
                          status: () => selected ? 3 : null,
                        );
                      },
                    ),
                    _buildChoiceChip(
                      label: 'Cancelled',
                      isSelected: criteria.status == 4,
                      onSelected: (selected) {
                        _criteriaNotifier.value = criteria.copyWith(
                          status: () => selected ? 4 : null,
                        );
                      },
                    ),
                    _buildChoiceChip(
                      label: 'No-Show',
                      isSelected: criteria.status == 5,
                      onSelected: (selected) {
                        _criteriaNotifier.value = criteria.copyWith(
                          status: () => selected ? 5 : null,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Party Size Filter
                Text(
                  'Minimum Guest Count',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChoiceChip(
                      label: 'Any Size',
                      isSelected: criteria.minGuests == null,
                      onSelected: (selected) {
                        if (selected) {
                          _criteriaNotifier.value = criteria.copyWith(
                            minGuests: () => null,
                          );
                        }
                      },
                    ),
                    _buildChoiceChip(
                      label: '1+ Guests',
                      isSelected: criteria.minGuests == 1,
                      onSelected: (selected) {
                        _criteriaNotifier.value = criteria.copyWith(
                          minGuests: () => selected ? 1 : null,
                        );
                      },
                    ),
                    _buildChoiceChip(
                      label: '3+ Guests',
                      isSelected: criteria.minGuests == 3,
                      onSelected: (selected) {
                        _criteriaNotifier.value = criteria.copyWith(
                          minGuests: () => selected ? 3 : null,
                        );
                      },
                    ),
                    _buildChoiceChip(
                      label: '5+ Guests',
                      isSelected: criteria.minGuests == 5,
                      onSelected: (selected) {
                        _criteriaNotifier.value = criteria.copyWith(
                          minGuests: () => selected ? 5 : null,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Filter
                Text(
                  'Time Frame',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChoiceChip(
                      label: 'All Time',
                      isSelected: criteria.dateFilter == 'all',
                      onSelected: (selected) {
                        if (selected) {
                          _criteriaNotifier.value = criteria.copyWith(
                            dateFilter: 'all',
                          );
                        }
                      },
                    ),
                    _buildChoiceChip(
                      label: 'Today',
                      isSelected: criteria.dateFilter == 'today',
                      onSelected: (selected) {
                        if (selected) {
                          _criteriaNotifier.value = criteria.copyWith(
                            dateFilter: 'today',
                          );
                        }
                      },
                    ),
                    _buildChoiceChip(
                      label: 'Tomorrow',
                      isSelected: criteria.dateFilter == 'tomorrow',
                      onSelected: (selected) {
                        if (selected) {
                          _criteriaNotifier.value = criteria.copyWith(
                            dateFilter: 'tomorrow',
                          );
                        }
                      },
                    ),
                    _buildChoiceChip(
                      label: 'Next 7 Days',
                      isSelected: criteria.dateFilter == 'this_week',
                      onSelected: (selected) {
                        if (selected) {
                          _criteriaNotifier.value = criteria.copyWith(
                            dateFilter: 'this_week',
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          context.tr(
                                shared.LocaleKeys.commonCancel,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Cancel',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(criteria);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          context.tr(
                                shared.LocaleKeys.commonApply,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Apply Filters',
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
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
