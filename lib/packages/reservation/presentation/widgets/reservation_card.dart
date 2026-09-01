import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../domain/entities/reservation_entity.dart';

class ReservationCard extends StatelessWidget {
  final ReservationEntity reservation;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onCustomerArrived;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onCustomerArrived,
  });

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.trim());
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.red;
      case 0:
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(BuildContext context, int? status) {
    switch (status) {
      case 1:
        return context.tr(
              shared.LocaleKeys.statusConfirmed,
              track: shared.TrackConstants.reservationPageTrack,
            ) ??
            'Confirmed';
      case 2:
        return context.tr(
              shared.LocaleKeys.statusCompleted,
              track: shared.TrackConstants.reservationPageTrack,
            ) ??
            'Completed';
      case 3:
        return context.tr(
              shared.LocaleKeys.statusCancelled,
              track: shared.TrackConstants.reservationPageTrack,
            ) ??
            'Cancelled';
      case 0:
      default:
        return context.tr(
              shared.LocaleKeys.statusPending,
              track: shared.TrackConstants.reservationPageTrack,
            ) ??
            'Pending';
    }
  }

  String _formatDateTime(String? rawDateTime) {
    if (rawDateTime == null || rawDateTime.isEmpty) return 'No Time';
    final dt = DateTime.tryParse(rawDateTime);
    if (dt != null) {
      final localDt = dt.toLocal();
      final now = DateTime.now();
      final isToday =
          localDt.year == now.year &&
          localDt.month == now.month &&
          localDt.day == now.day;

      final format = isToday
          ? core.DateUtil.timeFormat2
          : core.DateUtil.dateFormat16;

      final formatted = core.DateUtil.localFormatDateTime(dt, format);
      if (formatted != null) return formatted;
    }
    return rawDateTime.replaceAll('T', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(reservation.status);
    final hasPhone = reservation.phoneNumber?.trim().isNotEmpty == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onCustomerArrived,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reservation.customerName ?? 'Guest',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      _getStatusText(context, reservation.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: hasPhone
                          ? () => _makePhoneCall(reservation.phoneNumber)
                          : null,
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: hasPhone ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              hasPhone
                                  ? reservation.phoneNumber!
                                  : 'No Contact',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: hasPhone
                                        ? Colors.green.shade700
                                        : null,
                                    fontWeight: hasPhone
                                        ? FontWeight.w500
                                        : null,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildTableBadge(context),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDateTime(reservation.reservationDateTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  const Icon(Icons.group, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '${reservation.numberOfPeople ?? 0} Guests',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (reservation.occasion?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.cake, size: 16, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text(
                      reservation.occasion!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (reservation.preOrderedItems.isNotEmpty) ...[
                const Divider(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.restaurant_menu,
                      size: 16,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Pre-ordered (${reservation.preOrderedItems.fold(0, (sum, i) => sum + i.quantity)} items - ${reservation.preOrderedItems.fold(0.0, (sum, i) => sum + (i.price * i.quantity)).toStringAsFixed(2)}): ${reservation.preOrderedItems.map((e) => '${e.itemName} x${e.quantity}').join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onCustomerArrived != null && reservation.status != 2) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.event_seat,
                        size: 20,
                        color: Colors.orange,
                      ),
                      tooltip:
                          context.tr(
                            shared.LocaleKeys.customerShowUpButton,
                            track: shared.TrackConstants.reservationPageTrack,
                          ) ??
                          'Guest Arrived / Seat & Order',
                      onPressed: onCustomerArrived,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (hasPhone) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.call,
                        size: 20,
                        color: Colors.green,
                      ),
                      tooltip:
                          context.tr(
                            shared.LocaleKeys.callTooltip,
                            track: shared.TrackConstants.reservationPageTrack,
                          ) ??
                          'Call Customer',
                      onPressed: () => _makePhoneCall(reservation.phoneNumber),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableBadge(BuildContext context) {
    final track = shared.TrackConstants.reservationPageTrack;
    final labelText =
        context.tr(shared.LocaleKeys.selectTableLabel, track: track) ??
        'Table Assignment';
    final tableName = reservation.tableReservedName;

    if (tableName == null || tableName.trim().isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$labelText: ',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Chip(
            avatar: const Icon(Icons.table_restaurant, size: 14),
            label: const Text('N/A'),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      );
    }

    final tableList = tableName
        .split(', ')
        .where((t) => t.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.table_restaurant, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              '$labelText:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: tableList.map((t) {
            return Chip(
              avatar: const Icon(Icons.table_restaurant, size: 14),
              label: Text(t),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
    );
  }
}
