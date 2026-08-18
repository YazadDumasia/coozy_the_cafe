import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../domain/entities/reservation_entity.dart';
import '../bloc/reservation_action_cubit.dart';

class AddEditReservationScreenActions {
  static void submitForm({
    required BuildContext context,
    required bool isEdit,
    int? id,
    String? hashId,
    required String customerName,
    required String phone,
    required String isoCode,
    required String guestsStr,
    required DateTime? dateTime,
    required int? primaryTableId,
    required String combinedTableNames,
    required List<PreOrderedMenuItemEntity> selectedMenuItems,
    String? occasion,
    required String notes,
    required int status,
    required String? creationDate,
  }) {
    final entity = ReservationEntity(
      id: id,
      hashId: hashId,
      customerName: customerName.trim(),
      phoneNumber: phone.trim(),
      isoCode: isoCode,
      numberOfPeople: int.tryParse(guestsStr.trim()) ?? 1,
      reservationDateTime: dateTime?.toIso8601String(),
      tableId: primaryTableId,
      tableReservedName: combinedTableNames,
      preOrderedItems: selectedMenuItems,
      occasion: (occasion != null && occasion.trim().isNotEmpty) ? occasion.trim() : null,
      notes: notes.trim(),
      status: status,
      creationDate: creationDate,
    );

    final cubit = context.read<ReservationActionCubit>();
    if (isEdit) {
      cubit.updateReservation(entity);
    } else {
      cubit.createReservation(entity);
    }
  }

  static void onActionResult({
    required BuildContext context,
    required ReservationActionState state,
    required bool isEdit,
  }) {
    final track = shared.TrackConstants.reservationPageTrack;
    if (state is ReservationActionSuccess) {
      Navigator.pop(context, true);
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonSuccess,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Success',
        descriptions: isEdit
            ? (context.tr(
                    shared.LocaleKeys.reservationUpdatedSuccess,
                    track: track,
                  ) ??
                  'Reservation updated successfully.')
            : (context.tr(
                    shared.LocaleKeys.reservationCreatedSuccess,
                    track: track,
                  ) ??
                  'Reservation created successfully.'),
        titleIcon: Lottie.asset(
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Assets.lottie.doneLightBrownColor
              : Assets.lottie.doneBrownColor,
          repeat: false,
        ),
      );
    } else if (state is ReservationActionError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }
}
