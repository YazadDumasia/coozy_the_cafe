import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';

class MenuCategoryFullListScreenActions {
  static Future<void> handleNewCategory(BuildContext context) async {
    await context.push(
      '${core.AppRoutePath.menuCategoryFullListRoute}/${core.AppRoutePath.addNewMenuCategoryScreenRoute}',
    );
    if (context.mounted) {
      context.read<MenuCategoryFullListCubit>().loadData();
    }
  }

  static Future<void> handleEditCategory(
    BuildContext context,
    MenuCategory category,
  ) async {
    await context.push(
      '${core.AppRoutePath.menuCategoryFullListRoute}/${core.AppRoutePath.updateMenuCategoryScreenRoute}',
      extra: category,
    );
    if (context.mounted) {
      context.read<MenuCategoryFullListCubit>().loadData();
    }
  }

  static void handleDeleteCategory(
    BuildContext context,
    MenuCategory category,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.tr(
                shared.LocaleKeys.menuCategoryFullListDeleteDialogTitle,
                track: shared.TrackConstants.menuCategoryPageTrack,
              ) ??
              'Are you sure?',
        ),
        content: Text(
          context.tr(
                shared.LocaleKeys.menuCategoryFullListDeleteDialogSubTitle,
                track: shared.TrackConstants.menuCategoryPageTrack,
              ) ??
              'Do you really want to delete this category information? You will not be able to undo this action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr(
                    shared.LocaleKeys.commonCancel,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Cancel',
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              BlocProvider.of<MenuCategoryFullListCubit>(
                context,
              ).deletecategory(
                categoryId: category.id,
                category: category,
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
                      titleIcon: const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      ),
                    );
                  }
                },
              );
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

  static void handleToggleCategory(
    BuildContext context,
    MenuCategory category,
    bool isEnable,
  ) {
    BlocProvider.of<MenuCategoryFullListCubit>(context).handleIsEnableCategory(
      context,
      category,
      isEnable,
      onSuccess: () {
        if (context.mounted) {
          final catName = category.name ?? 'Category';
          Flushbar(
            message: isEnable
                ? (context.tr(
                      shared
                          .LocaleKeys
                          .menuCategoryFullListEnableToUpdateCategoryMsg,
                      params: {'catName': catName},
                      track: shared.TrackConstants.menuCategoryPageTrack,
                    ) ??
                    '$catName category is activated successfully.')
                : (context.tr(
                      shared
                          .LocaleKeys
                          .menuCategoryFullListUnableToUpdateCategoryMsg,
                      params: {'catName': catName},
                      track: shared.TrackConstants.menuCategoryPageTrack,
                    ) ??
                    '$catName category is deactivated successfully.'),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        }
      },
      onError: (error) {
        if (context.mounted) {
          Flushbar(
            message:
                context.tr(
                  shared.LocaleKeys.commonErrorMsg,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Failed to update category status.',
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        }
      },
    );
  }

  static void scrollToItemAndExpand({
    required BuildContext context,
    required String keyword,
    required ScrollController scrollController,
    required SearchController searchController,
  }) {
    final state = context.read<MenuCategoryFullListCubit>().state;
    if (state is MenuCategoryFullListLoadedState) {
      final MenuCategoryFullListLoadedState loadedState = state;

      if (keyword.isNotEmpty &&
          keyword != 'menu_category_search_no_suggestions') {
        if (searchController.isOpen) {
          searchController.closeView(keyword);
        }

        int index =
            (loadedState.data?['categories'] as List?)?.indexWhere((category) {
              final bool isCategoryMatch = category['name']
                  .toString()
                  .toLowerCase()
                  .contains(keyword.toLowerCase());

              if (isCategoryMatch) {
                return true;
              }

              if (category['subCategories'] != null) {
                return (category['subCategories'] as List).any(
                  (subCategory) => subCategory['name']
                      .toString()
                      .toLowerCase()
                      .contains(keyword.toLowerCase()),
                );
              }

              return false;
            }) ??
            -1;

        if (index != -1) {
          void doScrollAndExpand() {
            // 1. Expand the parent category tile if collapsed
            if (loadedState.expandedTitleControllerList != null &&
                index < loadedState.expandedTitleControllerList!.length &&
                loadedState.expandedTitleControllerList![index].isExpanded ==
                    false) {
              loadedState.expandedTitleControllerList![index].expand();
            }

            // 2. Wait for tile expansion animation to finish, then scroll to it
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!context.mounted) return;
              final targetContext =
                  loadedState.expansionTileKeys?[index]?.currentContext;
              if (targetContext != null) {
                Scrollable.ensureVisible(
                  targetContext,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  alignment: 0.0,
                );
              }
            });
          }

          // Execute after SearchAnchor view closes
          Future.delayed(const Duration(milliseconds: 200), () {
            doScrollAndExpand();
          });
        }
      } else {
        if (searchController.isOpen) {
          searchController.closeView(null);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      }
    }
  }
}
