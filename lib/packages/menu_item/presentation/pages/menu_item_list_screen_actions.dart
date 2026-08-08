import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_event.dart';

class MenuItemListScreenActions {
  static void handleAddMenuItem(BuildContext context) {
    context.push(AppRoutePath.addNewMenuItemScreenRoute).then((_) {
      if (context.mounted) {
        context.read<MenuItemBloc>().add(LoadMenuItems());
      }
    });
  }

  static void handleEditMenuItem(BuildContext context, MenuItem item) {
    context
        .push(
          AppRoutePath.updateMenuItemScreenRoute.replaceFirst(
            ':id',
            item.id.toString(),
          ),
          extra: item,
        )
        .then((_) {
          if (context.mounted) {
            context.read<MenuItemBloc>().add(LoadMenuItems());
          }
        });
  }

  static void handleDeleteMenuItem(BuildContext context, MenuItem item) {
    context.read<MenuItemBloc>().add(
      DeleteMenuItem(
        item.id!,
        onSuccess: () {
          if (context.mounted) {
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
                    shared.LocaleKeys.crudSuccessDelete,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Record deleted successfully.',
              titleIcon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
            );
          }
        },
        onError: (error) {
          if (context.mounted) {
            shared.DialogUtils.showAutoDismissDialog(
              context: context,
              title:
                  context.tr(
                    shared.LocaleKeys.commonError,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Error',
              descriptions: error.isNotEmpty
                  ? error
                  : (context.tr(
                          shared.LocaleKeys.commonErrorMsg,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'An error occurred.'),
              titleIcon: const Icon(Icons.error, color: Colors.red, size: 50),
            );
          }
        },
      ),
    );
  }
}
