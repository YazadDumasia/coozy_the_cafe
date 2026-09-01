import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../domain/entities/reservation_entity.dart';
import '../bloc/reservation_action_cubit.dart';
import 'main_reservation_screen_actions.dart';
import 'reservation_detail_screen_actions.dart';

class ReservationDetailScreen extends StatelessWidget {
  final ReservationEntity reservation;

  const ReservationDetailScreen({super.key, required this.reservation});

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.trim());
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = shared.TrackConstants.reservationPageTrack;
    final hasPhone = reservation.phoneNumber?.trim().isNotEmpty == true;

    return BlocListener<ReservationActionCubit, ReservationActionState>(
      listener: (context, state) =>
          ReservationDetailScreenActions.onActionResult(context, state),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.reservationDetailTitle,
                  track: track,
                ) ??
                'Reservation Details',
          ),
          actions: [
            if (reservation.status != 2)
              IconButton(
                icon: const Icon(Icons.event_seat, color: Colors.orange),
                tooltip:
                    context.tr(
                      shared.LocaleKeys.customerShowUpButton,
                      track: track,
                    ) ??
                    'Guest Arrived / Seat & Order',
                onPressed: () =>
                    MainReservationScreenActions.confirmCustomerArrival(
                      context,
                      reservation,
                    ),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => ReservationDetailScreenActions.onEditPressed(
                context,
                reservation,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => ReservationDetailScreenActions.confirmDelete(
                context,
                reservation,
              ),
            ),
          ],
        ),

        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        reservation.customerName ??
                            (context.tr(
                                  shared.LocaleKeys.guestLabel,
                                  track: track,
                                ) ??
                                'Guest'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        hasPhone
                            ? reservation.phoneNumber!
                            : (context.tr(
                                    shared.LocaleKeys.noContactDetails,
                                    track: track,
                                  ) ??
                                  'No contact details'),
                      ),
                      trailing: hasPhone
                          ? IconButton(
                              icon: const Icon(Icons.call, color: Colors.green),
                              tooltip:
                                  context.tr(
                                    shared.LocaleKeys.callTooltip,
                                    track: track,
                                  ) ??
                                  'Call',
                              onPressed: () =>
                                  _makePhoneCall(reservation.phoneNumber),
                            )
                          : null,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildTableInfoRow(context, track),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today,
                      label:
                          context.tr(
                            shared.LocaleKeys.dateTimeLabel,
                            track: track,
                          ) ??
                          'Date & Time',
                      value:
                          core.DateUtil.localFormat(
                            reservation.reservationDateTime,
                            core.DateUtil.dateFormat16,
                          ) ??
                          (context.tr(
                                shared.LocaleKeys.commonNil,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'N/A'),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      icon: Icons.group,
                      label:
                          context.tr(
                            shared.LocaleKeys.numberOfPeopleLabel,
                            track: track,
                          ) ??
                          'Guest Count',
                      value:
                          '${reservation.numberOfPeople ?? 0} ${context.tr(shared.LocaleKeys.peopleSuffix, track: track) ?? 'People'}',
                    ),
                    if (reservation.occasion?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        icon: Icons.cake,
                        label:
                            context.tr(
                              shared.LocaleKeys.occasionLabel,
                              track: track,
                            ) ??
                            'Occasion',
                        value: reservation.occasion!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      icon: Icons.info_outline,
                      label:
                          context.tr(
                            shared.LocaleKeys.statusLabel,
                            track: track,
                          ) ??
                          'Status',
                      value: _getStatusName(context, reservation.status, track),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (reservation.preOrderedItems.isNotEmpty) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                              shared.LocaleKeys.selectMenuItemsLabel,
                              track: track,
                            ) ??
                            'Pre-ordered Menu Items',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...reservation.preOrderedItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}x ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(child: Text(item.itemName)),
                              Text(
                                (item.price * item.quantity).toStringAsFixed(2),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (reservation.notes?.isNotEmpty == true)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                              shared.LocaleKeys.notesLabel,
                              track: track,
                            ) ??
                            'Notes',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(reservation.notes!),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableInfoRow(BuildContext context, String track) {
    final textTheme = Theme.of(context).textTheme;
    final tableName = reservation.tableReservedName;
    final label =
        context.tr(shared.LocaleKeys.tableAssignmentLabel, track: track) ??
        'Table Assignment';
    final notAssigned =
        context.tr(shared.LocaleKeys.notAssigned, track: track) ??
        'Not Assigned';

    if (tableName == null || tableName.isEmpty) {
      return _buildInfoRow(
        context,
        icon: Icons.table_restaurant,
        label: label,
        value: notAssigned,
      );
    }

    final tableList = tableName
        .split(', ')
        .where((t) => t.trim().isNotEmpty)
        .toList();

    if (tableList.length <= 1) {
      return _buildInfoRow(
        context,
        icon: Icons.table_restaurant,
        label: label,
        value: tableName,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.table_restaurant,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                children: tableList
                    .map(
                      (t) => Chip(
                        avatar: const Icon(Icons.table_restaurant, size: 14),
                        label: Text(t, style: textTheme.bodySmall),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _getStatusName(BuildContext context, int? status, String track) {
    switch (status) {
      case 1:
        return context.tr(shared.LocaleKeys.statusConfirmed, track: track) ??
            'Confirmed';
      case 2:
        return context.tr(shared.LocaleKeys.statusCompleted, track: track) ??
            'Completed';
      case 3:
        return context.tr(shared.LocaleKeys.statusCancelled, track: track) ??
            'Cancelled';
      case 0:
      default:
        return context.tr(shared.LocaleKeys.statusPending, track: track) ??
            'Pending';
    }
  }
}
