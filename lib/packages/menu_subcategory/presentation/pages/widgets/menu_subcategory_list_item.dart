import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import '../menu_subcategory_full_list_screen_actions.dart';

class MenuSubcategoryListItem extends StatelessWidget {
  final MenuSubcategory subCategory;
  final bool isLastItem;

  const MenuSubcategoryListItem({
    super.key,
    required this.subCategory,
    required this.isLastItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.only(bottom: isLastItem ? 0 : 10, left: 10, right: 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
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
                            text: 'Active Status: ',
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: <InlineSpan>[
                              TextSpan(
                                text: subCategory.isActive == false
                                    ? 'Inactive'
                                    : 'Active',
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
            SizedBox(
              height: 30,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Switch.adaptive(
                  value: subCategory.isActive == true,
                  onChanged:
                      (bool isEnable) =>
                          MenuSubcategoryFullListScreenActions.handleToggleSubcategory(
                            context,
                            subCategory,
                            isEnable,
                          ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                onPressed:
                    () =>
                        MenuSubcategoryFullListScreenActions.handleEditSubcategory(
                          context,
                          subCategory,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
