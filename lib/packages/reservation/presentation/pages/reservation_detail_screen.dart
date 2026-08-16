import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../domain/entities/reservation_entity.dart';
import '../bloc/reservation_action_cubit.dart';
import 'reservation_detail_screen_actions.dart';

class ReservationDetailScreen extends StatelessWidget {
  final ReservationEntity reservation;

  const ReservationDetailScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final track = shared.TrackConstants.reservationPageTrack;

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
                        reservation.customerName ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        reservation.phoneNumber?.isNotEmpty == true
                            ? reservation.phoneNumber!
                            : 'No contact details',
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Icons.table_restaurant,
                      'Table Assignment',
                      reservation.tableReservedName ?? 'Not Assigned',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today,
                      'Date & Time',
                      reservation.reservationDateTime != null
                          ? reservation.reservationDateTime!.replaceAll(
                              'T',
                              ' ',
                            )
                          : 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.group,
                      'Guest Count',
                      '${reservation.numberOfPeople ?? 0} People',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.info_outline,
                      'Status',
                      _getStatusName(reservation.status),
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
                                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
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

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  String _getStatusName(int? status) {
    switch (status) {
      case 1:
        return 'Confirmed';
      case 2:
        return 'Completed';
      case 3:
        return 'Cancelled';
      case 0:
      default:
        return 'Pending';
    }
  }
}
