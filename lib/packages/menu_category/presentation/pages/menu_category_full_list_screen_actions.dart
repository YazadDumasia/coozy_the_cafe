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
                      title: context.tr(
                        shared.LocaleKeys.commonSuccess,
                        track: shared.TrackConstants.commonTrack,
                      ) ?? 'Success',
                      descriptions: context.tr(
                        shared.LocaleKeys.crudSuccessDelete,
                        track: shared.TrackConstants.commonTrack,
                      ) ?? 'Record deleted successfully.',
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
                      title: context.tr(
                        shared.LocaleKeys.commonError,
                        track: shared.TrackConstants.commonTrack,
                      ) ?? 'Error',
                      descriptions: error.isNotEmpty
                          ? error
                          : (context.tr(
                              shared.LocaleKeys.commonErrorMsg,
                              track: shared.TrackConstants.commonTrack,
                            ) ?? 'An error occurred.'),
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
    BlocProvider.of<MenuCategoryFullListCubit>(
      context,
    ).handleIsEnableCategory(context, category, isEnable);
  }

  static void scrollToItemAndExpand({
    required BuildContext context,
    required String keyword,
    required ScrollController scrollController,
    required SearchController searchController,
  }) {
    final cubitState = context.read<MenuCategoryFullListCubit>().state;
    if (cubitState is MenuCategoryFullListLoadedState) {
      if (keyword.isNotEmpty &&
          keyword != 'menu_category_search_no_suggestions') {
        int index = cubitState.data!['categories'].indexWhere((category) {
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
        });

        if (index != -1) {
          // Obtain the RenderBox
          final currentContext =
              cubitState.expansionTileKeys![index]?.currentContext;
          if (currentContext != null) {
            final RenderBox renderBox =
                currentContext.findRenderObject() as RenderBox;
            final double itemHeight = renderBox.size.height;
            final double position = index * itemHeight;

            if ((cubitState.expandedTitleControllerList != null ||
                    cubitState.expandedTitleControllerList!.isNotEmpty) &&
                cubitState.expandedTitleControllerList![index].isExpanded ==
                    false) {
              cubitState.expandedTitleControllerList![index].expand();
            }

            scrollController.animateTo(
              position,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      } else {
        if (searchController.isOpen == true) {
          Navigator.of(context).pop();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      }
    }
  }
}
