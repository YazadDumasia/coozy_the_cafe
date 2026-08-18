import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../bloc/current_reservation_cubit.dart';
import '../bloc/upcoming_reservation_bloc.dart';
import '../bloc/reservation_action_cubit.dart';
import '../../domain/entities/reservation_entity.dart';
import 'add_edit_reservation_screen.dart';
import 'reservation_detail_screen.dart';
import '../widgets/reservation_filter_bottom_sheet.dart';

class MainReservationScreenActions {
  static void showFilterBottomSheet({
    required BuildContext context,
    required ReservationFilterCriteria initialCriteria,
    required ValueChanged<ReservationFilterCriteria> onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationFilterBottomSheet(
        initialCriteria: initialCriteria,
        onApply: onApply,
      ),
    );
  }

  static void onScroll(
    BuildContext context,
    ScrollController scrollController,
  ) {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      context.read<UpcomingReservationBloc>().add(
        const FetchUpcomingReservations(),
      );
    }
  }

  static void onSearchChanged(BuildContext context, String query) {
    context.read<UpcomingReservationBloc>().add(
      SearchUpcomingReservations(query),
    );
  }

  static void refreshAll(BuildContext context) {
    context.read<CurrentReservationCubit>().fetchCurrentReservations();
    context.read<UpcomingReservationBloc>().add(
      const FetchUpcomingReservations(isRefresh: true),
    );
  }

  static Future<void> openAddScreen(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ReservationActionCubit>(),
          child: const AddEditReservationScreen(),
        ),
      ),
    );
    if (result == true && context.mounted) {
      refreshAll(context);
    }
  }

  static Future<void> onTapReservation(
    BuildContext context,
    ReservationEntity item,
  ) async {
    final res = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ReservationActionCubit>()),
            BlocProvider.value(value: context.read<CurrentReservationCubit>()),
            BlocProvider.value(value: context.read<UpcomingReservationBloc>()),
          ],
          child: ReservationDetailScreen(reservation: item),
        ),
      ),
    );
    if (res == true && context.mounted) {
      refreshAll(context);
    }
  }

  static Future<void> onEditReservation(
    BuildContext context,
    ReservationEntity item,
  ) async {
    final res = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ReservationActionCubit>(),
          child: AddEditReservationScreen(reservation: item),
        ),
      ),
    );
    if (res == true && context.mounted) {
      refreshAll(context);
    }
  }

  static void confirmDeleteReservation(
    BuildContext context, {
    required ReservationEntity item,
    required VoidCallback onConfirmed,
  }) {
    final track = shared.TrackConstants.reservationPageTrack;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          context.tr(shared.LocaleKeys.deleteReservationTitle, track: track) ??
              'Delete Reservation?',
        ),
        content: Text(
          context.tr(
                shared.LocaleKeys.deleteReservationSubtitle,
                track: track,
              ) ??
              'Are you sure you want to delete this reservation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              context.tr(
                    shared.LocaleKeys.commonCancel,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              onConfirmed();
            },
            child: Text(
              context.tr(
                    shared.LocaleKeys.commonDelete,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  static void onDeleteCurrentReservation(
    BuildContext context,
    ReservationEntity item,
  ) {
    if (item.id == null) return;
    confirmDeleteReservation(
      context,
      item: item,
      onConfirmed: () {
        context.read<CurrentReservationCubit>().removeReservation(item.id!);
        context.read<ReservationActionCubit>().deleteReservation(item.id!);
      },
    );
  }

  static void onDeleteUpcomingReservation(
    BuildContext context,
    ReservationEntity item,
  ) {
    if (item.id == null) return;
    confirmDeleteReservation(
      context,
      item: item,
      onConfirmed: () {
        context.read<UpcomingReservationBloc>().add(
          RemoveUpcomingReservation(item.id!),
        );
        context.read<ReservationActionCubit>().deleteReservation(item.id!);
      },
    );
  }
}
