import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import '../../pages/menu_subcategory_full_list/menu_subcategory_full_list_screen_actions.dart';

class MenuSubcategoryGridCard extends StatelessWidget {
  final MenuSubcategory subCategory;

  const MenuSubcategoryGridCard({super.key, required this.subCategory});

  Color _getAvatarColor(String text, BuildContext context) {
    if (text.isEmpty) return Theme.of(context).primaryColor;
    final int hash = text.codeUnits.fold(0, (prev, elem) => prev + elem);
    final List<Color> colors = [
      Colors.deepOrange,
      Colors.indigo,
      Colors.teal,
      Colors.purple,
      Colors.pink,
      Colors.blueGrey,
      Colors.amber.shade800,
      Colors.brown,
      Colors.blue,
      Colors.green.shade700,
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final String name = subCategory.name ?? '';
    final String initialChar = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final Color avatarColor = _getAvatarColor(name, context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Header: CircleAvatar with Initial Char
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor,
              child: Text(
                initialChar,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Status row with Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subCategory.isActive == true
                      ? (context.tr(
                              shared.LocaleKeys.commonActive,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Active')
                      : (context.tr(
                              shared.LocaleKeys.commonInactive,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Inactive'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subCategory.isActive == true
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  height: 20,
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
              ],
            ),
            const Divider(height: 8, thickness: 0.5),
            // Action Buttons: Edit and Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () =>
                      MenuSubcategoryFullListScreenActions.handleEditSubcategory(
                        context,
                        subCategory,
                      ),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () =>
                      MenuSubcategoryFullListScreenActions.handleDeleteSubcategory(
                        context,
                        subCategory,
                      ),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
