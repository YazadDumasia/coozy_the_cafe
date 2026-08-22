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

  @override
  List<Object?> get props => [activeCategories, categoryDataList];
}
