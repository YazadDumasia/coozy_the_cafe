import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_info.dart';
import 'package:coozy_the_cafe/packages/table_management/presentation/cubit/table_cubit.dart';
import 'package:coozy_the_cafe/packages/table_management/presentation/pages/new_table_info_dialog/new_table_info_dialog.dart';
import 'package:coozy_the_cafe/packages/table_management/presentation/pages/table_update_dialog/table_update_dialog.dart';

class TableScreenActions {
  static Future<void> onReorder(
    BuildContext context,
    int oldIndex,
    int newIndex,
  ) async {
    shared.DialogUtils.showLoadingDialog(context);
    await context.read<TableCubit>().reorderTables(oldIndex, newIndex);
    if (context.mounted) Navigator.pop(context);
  }

  static Future<void> onToggleView(
    BuildContext context,
    TableLoaded state,
  ) async {
    if (state.isReorderAllowed == false) {
      context.read<TableCubit>().toggleView();
    } else {
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonError,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Error',
        descriptions:
            context.tr(
              shared.LocaleKeys.disableReorderIconTableIconTooltipText,
              track: shared.TrackConstants.tablePageTrack,
            ) ??
            'Please switch off reorder list feature',
        titleIcon: const Icon(
          Icons.info_outline,
          color: Colors.orange,
          size: 50,
        ),
      );
    }
  }

  static Future<void> onToggleReorder(BuildContext context) async {
    context.read<TableCubit>().toggleReorder();
  }

  static Future<void> onRetry(BuildContext context) async {
    context.read<TableCubit>().loadTables();
  }

  static Future<void> onDeleteTable(
    BuildContext context,
    TableInfo model,
  ) async {
    shared.DialogUtils.showConfirmationDialog(
      context: context,
      title:
          context.tr(
            shared.LocaleKeys.tableScreenDeleteTitleTxt,
            track: shared.TrackConstants.tablePageTrack,
          ) ??
          'Are you sure?',
      content:
          context.tr(
            shared.LocaleKeys.tableScreenDeleteSubTitleTxt,
            track: shared.TrackConstants.tablePageTrack,
          ) ??
          'Do you really want to delete this table information? You will not be able to undo this action.',
      cancelText:
          context.tr(
            shared.LocaleKeys.commonCancel,
            track: shared.TrackConstants.commonTrack,
          ) ??
          'Cancel',
      confirmText:
          context.tr(
            shared.LocaleKeys.commonOkay,
            track: shared.TrackConstants.commonTrack,
          ) ??
          'Okay',
      titleIcon: Icon(
        Icons.info_outline,
        size: 50,
        color: Theme.of(context).primaryColor,
      ),
      onCancel: () => Navigator.pop(context),
      onConfirm: () async {
        Navigator.pop(context);
        shared.DialogUtils.showLoadingDialog(context);
        context.read<TableCubit>().deleteTable(
          model.id!,
          onSuccess: () {
            if (context.mounted) {
              Navigator.pop(context); // Pop loading dialog
              shared.DialogUtils.showAutoDismissDialog(
                context: context,
                descriptions:
                    context.tr(
                      shared.LocaleKeys.tableDeletedSuccessfullyText,
                      track: shared.TrackConstants.tablePageTrack,
                    ) ??
                    'Select table has been deleted successfully.',
                title: '',
                titleIcon: Lottie.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Assets.lottie.doneLightBrownColor
                      : Assets.lottie.doneBrownColor,
                  repeat: false,
                ),
              );
            }
          },
          onError: (error) {
            core.PlatformUtils.debugLog(
              TableScreenActions,
              'onDeleteTable:onError: $error',
            );
            if (context.mounted) {
              Navigator.pop(context); // Pop loading dialog
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
                            shared.LocaleKeys.tableDeletedSuccessfullyText,
                            track: shared.TrackConstants.tablePageTrack,
                          ) ??
                          'Failed to delete you select table.'),
                titleIcon: Lottie.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Assets.lottie.errorLightLoaderIcon
                      : Assets.lottie.errorDarkLoaderIcon,
                  repeat: false,
                ),
              );
            }
          },
        );
      },
    );
  }

  static Future<void> onUpdateModel(
    BuildContext context,
    TableInfo model,
  ) async {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TableCubit>(),
        child: TableUpdateDialog(
          table: model,
          onUpdate: (updatedTable) async {
            Navigator.pop(context);
            shared.DialogUtils.showLoadingDialog(context);
            context.read<TableCubit>().updateTable(
              updatedTable,
              onSuccess: () {
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading dialog
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
                          shared.LocaleKeys.tableToastUpdatedSuccessfully,
                          track: shared.TrackConstants.tablePageTrack,
                        ) ??
                        'Table updated successfully.',
                    titleIcon: Lottie.asset(
                      MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Assets.lottie.doneLightBrownColor
                          : Assets.lottie.doneBrownColor,
                      repeat: false,
                    ),
                  );
                }
              },
              onError: (error) {
                core.PlatformUtils.debugLog(
                  TableScreenActions,
                  'onUpdateModel:onError: $error',
                );
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading dialog
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
                              'Something went wrong. Please try again.'),
                    titleIcon: Lottie.asset(
                      MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Assets.lottie.errorLightLoaderIcon
                          : Assets.lottie.errorDarkLoaderIcon,
                      repeat: false,
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  static Future<void> addNewTableInfo(BuildContext dialogContext) async {
    await showDialog(
      context: dialogContext,
      builder: (_) => BlocProvider.value(
        value: dialogContext.read<TableCubit>(),
        child: NewTableInfoDialog(
          onCreate: (newTableInfo) async {
            Navigator.of(dialogContext).pop();
            shared.DialogUtils.showLoadingDialog(dialogContext);
            dialogContext.read<TableCubit>().addTable(
              newTableInfo,
              onSuccess: () {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext); // Pop loading dialog
                  shared.DialogUtils.showAutoDismissDialog(
                    context: dialogContext,
                    title:
                        dialogContext.tr(
                          shared.LocaleKeys.commonSuccess,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Success',
                    descriptions:
                        dialogContext.tr(
                          shared.LocaleKeys.tableAddedSuccessfullyText,
                          track: shared.TrackConstants.tablePageTrack,
                        ) ??
                        'New table has been added successfully.',
                    titleIcon: Lottie.asset(
                      MediaQuery.of(dialogContext).platformBrightness ==
                              Brightness.light
                          ? Assets.lottie.doneLightBrownColor
                          : Assets.lottie.doneBrownColor,
                      repeat: false,
                    ),
                  );
                }
              },
              onError: (error) {
                core.PlatformUtils.debugLog(
                  TableScreenActions,
                  'addNewTableInfo:onError: $error',
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext); // Pop loading dialog
                  shared.DialogUtils.showAutoDismissDialog(
                    context: dialogContext,
                    title:
                        dialogContext.tr(
                          shared.LocaleKeys.commonError,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Error',
                    descriptions: error.isNotEmpty
                        ? error
                        : (dialogContext.tr(
                                shared.LocaleKeys.commonErrorMsg,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Something went wrong. Please try again.'),
                    titleIcon: Lottie.asset(
                      MediaQuery.of(dialogContext).platformBrightness ==
                              Brightness.light
                          ? Assets.lottie.errorLightLoaderIcon
                          : Assets.lottie.errorDarkLoaderIcon,
                      repeat: false,
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
