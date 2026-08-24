import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/menu_item.dart';
import '../../bloc/menu_item_bloc.dart';

class MenuItemDetailActions {
  static void handleEditMenuItem(BuildContext context, MenuItem item) async {
    await context.push(
      '${AppRoutePath.menuItemFullListScreenRoute}/${AppRoutePath.updateMenuItemScreenRoute}',
      extra: item,
    );
    if (context.mounted) {
      context.read<MenuItemBloc>().add(const LoadMenuItems(isSilent: true));
    }
  }

  static void handleDeleteMenuItem(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.tr(
                shared.LocaleKeys.commonDelete,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Delete',
        ),
        content: Text(
          context.tr(
                    shared.LocaleKeys.commonDelete,
                    track: shared.TrackConstants.commonTrack,
                  ) !=
                  null
              ? 'Are you sure you want to delete this menu item?'
              : 'Are you sure you want to delete this menu item?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              context.tr(
                    shared.LocaleKeys.commonCancel,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Cancel',
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (item.id != null) {
                context.read<MenuItemBloc>().add(
                  DeleteMenuItem(
                    item.id!,
                    onSuccess: () {
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                );
              }
            },
            child: Text(
              context.tr(
                    shared.LocaleKeys.commonDelete,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Delete',
            ),
          ),
        ],
      ),
    );
  }
}
