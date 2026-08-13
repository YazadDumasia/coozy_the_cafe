import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import '../../pages/menu_subcategory_full_list/menu_subcategory_full_list_screen_actions.dart';

class MenuSubcategoryListItem extends StatelessWidget {
  final MenuSubcategory subCategory;
  final bool isLastItem;
  final bool isReorderMode;
  final int index;

  const MenuSubcategoryListItem({
    super.key,
    required this.subCategory,
    required this.isLastItem,
    this.isReorderMode = false,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.only(bottom: isLastItem ? 0 : 10, left: 10, right: 10),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${subCategory.name}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: RichText(
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
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: <InlineSpan>[
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: subCategory.isActive == false
                                    ? (context.tr(
                                            shared.LocaleKeys.commonInactive,
                                            track: shared
                                                .TrackConstants
                                                .commonTrack,
                                          ) ??
                                          'Inactive')
                                    : (context.tr(
                                            shared.LocaleKeys.commonActive,
                                            track: shared
                                                .TrackConstants
                                                .commonTrack,
                                          ) ??
                                          'Active'),
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: subCategory.isActive == false
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isReorderMode)
              ReorderableDragStartListener(
                index: index,
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ),
              ),
            if (!isReorderMode) ...[
              SizedBox(
                height: 30,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch.adaptive(
                    value: subCategory.isActive == true,
                    onChanged: (bool isEnable) =>
                        MenuSubcategoryFullListScreenActions.handleToggleSubcategory(
                          context,
                          subCategory,
                          isEnable,
                        ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    thumbIcon: WidgetStateProperty.resolveWith<Icon>((
                      Set<WidgetState> states,
                    ) {
                      if (states.containsAll(<Object?>[
                        WidgetState.disabled,
                        WidgetState.selected,
                      ])) {
                        return const Icon(
                          Icons.check,
                          color: Colors.red,
                          size: 24,
                        );
                      }
                      if (states.contains(WidgetState.disabled)) {
                        return const Icon(Icons.close, size: 24);
                      }
                      if (states.contains(WidgetState.selected)) {
                        return const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 24,
                        );
                      }
                      return const Icon(Icons.close, size: 24);
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                shape: const CircleBorder(),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () =>
                      MenuSubcategoryFullListScreenActions.handleEditSubcategory(
                        context,
                        subCategory,
                      ),
                ),
              ),
              const SizedBox(width: 6),
              Material(
                shape: const CircleBorder(),
                color: Colors.red.shade100,
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  onPressed: () =>
                      MenuSubcategoryFullListScreenActions.handleDeleteSubcategory(
                        context,
                        subCategory,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
