import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:equatable/equatable.dart';

class MenuCatalogCategoryData extends Equatable {
  final Category category;
  final List<Subcategory> subcategories;
  final List<MenuItemWithVariations> uncategorizedItems;
  final Map<int, List<MenuItemWithVariations>> subcategoryItems;

  const MenuCatalogCategoryData({
    required this.category,
    this.subcategories = const [],
    this.uncategorizedItems = const [],
    this.subcategoryItems = const {},
  });

  bool get hasItems =>
      uncategorizedItems.isNotEmpty ||
      subcategoryItems.values.any((items) => items.isNotEmpty);

  int get totalItemCount {
    int count = uncategorizedItems.length;
    for (final items in subcategoryItems.values) {
      count += items.length;
    }
    return count;
  }

  @override
  List<Object?> get props => [
    category,
    subcategories,
    uncategorizedItems,
    subcategoryItems,
  ];
}

class MenuCatalogData extends Equatable {
  final List<Category> activeCategories;
  final List<MenuCatalogCategoryData> categoryDataList;

  const MenuCatalogData({
    this.activeCategories = const [],
    this.categoryDataList = const [],
  });

  List<Category> getDisplayCategories({bool displayEmptyViewForTab = false}) {
    if (displayEmptyViewForTab) return activeCategories;
    return categoryDataList
        .where((cd) => cd.hasItems)
        .map((cd) => cd.category)
        .toList();
  }

  List<MenuCatalogCategoryData> getDisplayCategoryDataList({
    bool displayEmptyViewForTab = false,
  }) {
    if (displayEmptyViewForTab) return categoryDataList;
    return categoryDataList.where((cd) => cd.hasItems).toList();
  }

  @override
  List<Object?> get props => [activeCategories, categoryDataList];
}
