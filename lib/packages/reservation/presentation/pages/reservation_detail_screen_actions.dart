import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../domain/entities/reservation_entity.dart';
import '../bloc/current_reservation_cubit.dart';
import '../bloc/upcoming_reservation_bloc.dart';
import '../bloc/reservation_action_cubit.dart';
import 'add_edit_reservation_screen.dart';

class ReservationDetailScreenActions {
  static void confirmDelete(
    BuildContext context,
    ReservationEntity reservation,
  ) {
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
              if (reservation.id != null) {
                try {
                  context.read<CurrentReservationCubit>().removeReservation(
                    reservation.id!,
                  );
                } catch (_) {}
                try {
                  context.read<UpcomingReservationBloc>().add(
                    RemoveUpcomingReservation(reservation.id!),
                  );
                } catch (_) {}
                context.read<ReservationActionCubit>().deleteReservation(
                  reservation.id!,
                );
              }
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

  static Future<void> onEditPressed(
    BuildContext context,
    ReservationEntity reservation,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ReservationActionCubit>(),
          child: AddEditReservationScreen(reservation: reservation),
        ),
      ),
    );
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  static void onActionResult(
    BuildContext context,
    ReservationActionState state,
  ) {
    final track = shared.TrackConstants.reservationPageTrack;
    if (state is ReservationConvertedToOrderSuccess) {
      Navigator.pop(context, true);
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonSuccess,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Success',
        descriptions:
            context.tr(
              shared.LocaleKeys.customerShowUpSuccess,
              track: track,
            ) ??
            'Reservation converted to active order successfully!',
        titleIcon: Lottie.asset(
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Assets.lottie.doneLightBrownColor
              : Assets.lottie.doneBrownColor,
          repeat: false,
        ),
      );
    } else if (state is ReservationActionSuccess) {
      Navigator.pop(context, true);
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonSuccess,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Success',
        descriptions:
            context.tr(
              shared.LocaleKeys.reservationDeletedSuccess,
              track: track,
            ) ??
            'Reservation deleted successfully.',
        titleIcon: Lottie.asset(
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Assets.lottie.doneLightBrownColor
              : Assets.lottie.doneBrownColor,
          repeat: false,
        ),
      );
    }
  }
}
