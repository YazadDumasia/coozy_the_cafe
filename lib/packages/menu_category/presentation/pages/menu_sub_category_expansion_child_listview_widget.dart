import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class MenuSubCategoryExpansionChildListViewWidget extends StatefulWidget {
  const MenuSubCategoryExpansionChildListViewWidget({
    super.key,
    this.subCategoryList,
    this.itemsToShow,
  });
  final List<MenuSubcategory>? subCategoryList;
  final int? itemsToShow;

  @override
  State<MenuSubCategoryExpansionChildListViewWidget> createState() =>
      _MenuSubCategoryExpansionChildListViewWidgetState();
}

class _MenuSubCategoryExpansionChildListViewWidgetState
    extends State<MenuSubCategoryExpansionChildListViewWidget> {
  late ValueNotifier<int> _itemsToShowNotifier;

  final WidgetStateProperty<Icon?>? thumbIcon =
      WidgetStateProperty.resolveWith<Icon>((Set<WidgetState> states) {
        if (states.containsAll(<Object?>[
          WidgetState.disabled,
          WidgetState.selected,
        ])) {
          return const Icon(Icons.check, color: Colors.red);
        }

        if (states.contains(WidgetState.disabled)) {
          return const Icon(Icons.close);
        }

        if (states.contains(WidgetState.selected)) {
          return const Icon(Icons.check, color: Colors.green);
        }

        return const Icon(Icons.close);
      });

  @override
  void initState() {
    super.initState();
    _itemsToShowNotifier = ValueNotifier<int>(widget.itemsToShow ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _itemsToShowNotifier,
      builder: (context, itemsToShow, _) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          slivers: <Widget>[
            const SliverToBoxAdapter(child: Divider(thickness: 2)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final MenuSubcategory subCategory =
                      widget.subCategoryList![index];
                  // Check if it's the first or last item
                  final bool isFirst = index == 0;
                  final bool isLast =
                      index == (widget.subCategoryList!.length - 1);

                  return Padding(
                    padding: EdgeInsets.only(
                      top: isFirst ? 10 : 5,
                      bottom: isLast ? 10 : 5,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.subdirectory_arrow_right,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(subCategory.name ?? ''),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    RichText(
                                      text: TextSpan(
                                        text:
                                            context.tr(
                                              shared
                                                  .LocaleKeys
                                                  .menuCategoryFullListEnableStatusText,
                                              track: shared
                                                  .TrackConstants
                                                  .menuCategoryPageTrack,
                                            ) ??
                                            'Enable Status:',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                        children: <InlineSpan>[
                                          TextSpan(text: ' '),
                                          TextSpan(
                                            text:
                                                (subCategory.isActive ?? false)
                                                ? context.tr(
                                                        shared
                                                            .LocaleKeys
                                                            .commonActive,
                                                        track: shared
                                                            .TrackConstants
                                                            .commonTrack,
                                                      ) ??
                                                      'Active'
                                                : context.tr(
                                                        shared
                                                            .LocaleKeys
                                                            .commonInactive,
                                                        track: shared
                                                            .TrackConstants
                                                            .commonTrack,
                                                      ) ??
                                                      'Inactive',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color:
                                                      (subCategory.isActive ??
                                                          false)
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Switch.adaptive(
                                            value: subCategory.isActive == true,
                                            onChanged: (bool isEnable) async {
                                              BlocProvider.of<MenuCategoryFullListCubit>(
                                                context,
                                              ).handleIsEnableSubCategory(
                                                context,
                                                subCategory,
                                                isEnable,
                                                onSuccess: () {
                                                  if (context.mounted) {
                                                    final subName =
                                                        subCategory.name ??
                                                        'Sub-category';
                                                    Flushbar(
                                                      message: isEnable
                                                          ? '$subName sub-category is activated successfully.'
                                                          : '$subName sub-category is deactivated successfully.',
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                      margin:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ).show(context);
                                                  }
                                                },
                                                onError: (error) {
                                                  if (context.mounted) {
                                                    Flushbar(
                                                      message:
                                                          context.tr(
                                                            shared
                                                                .LocaleKeys
                                                                .menuCategoryFullListFailedToUpdateSubCategoryMsg,
                                                            track: shared
                                                                .TrackConstants
                                                                .menuCategoryPageTrack,
                                                          ) ??
                                                          'Failed to update sub-category status.',
                                                      backgroundColor:
                                                          Colors.red,
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                      margin:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ).show(context);
                                                  }
                                                },
                                              );
                                            },
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            thumbIcon: thumbIcon,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: min(itemsToShow, widget.subCategoryList!.length)),
              ),
            ),
            if (widget.subCategoryList!.length > itemsToShow)
              SliverPadding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        // Increase the itemsToShow to load the next set of items
                        _itemsToShowNotifier.value =
                            itemsToShow + (widget.itemsToShow ?? 0);
                      },
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.commonLoadMore,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Load More',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _itemsToShowNotifier.dispose();
    super.dispose();
  }
}
