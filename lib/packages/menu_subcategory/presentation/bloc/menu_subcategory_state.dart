part of 'menu_subcategory_bloc.dart';

sealed class MenuSubcategoryState extends Equatable {
  const MenuSubcategoryState();

  @override
  List<Object?> get props => [];
}

class MenuSubcategoryInitial extends MenuSubcategoryState {}

class MenuSubcategoryLoading extends MenuSubcategoryState {}

class MenuSubcategoryLoaded extends MenuSubcategoryState {
  final List<MenuSubcategory> subcategories;
  final List<MenuSubcategory>? initialSubcategories;
  final bool isReorderAllowed;
  final int? categoryIdFilter;
  final bool isSearchActive;

  const MenuSubcategoryLoaded({
    required this.subcategories,
    this.initialSubcategories,
    this.isReorderAllowed = false,
    this.categoryIdFilter,
    this.isSearchActive = false,
  });

  MenuSubcategoryLoaded copyWith({
    List<MenuSubcategory>? subcategories,
    List<MenuSubcategory>? initialSubcategories,
    bool? isReorderAllowed,
    int? categoryIdFilter,
    bool clearCategoryIdFilter = false,
    bool? isSearchActive,
  }) {
    return MenuSubcategoryLoaded(
      subcategories: subcategories ?? this.subcategories,
      initialSubcategories: initialSubcategories ?? this.initialSubcategories,
      isReorderAllowed: isReorderAllowed ?? this.isReorderAllowed,
      categoryIdFilter: clearCategoryIdFilter
          ? categoryIdFilter
          : (categoryIdFilter ?? this.categoryIdFilter),
      isSearchActive: isSearchActive ?? this.isSearchActive,
    );
  }

  @override
  List<Object?> get props => [
    subcategories,
    initialSubcategories,
    isReorderAllowed,
    categoryIdFilter,
    isSearchActive,
  ];
}

class MenuSubcategoryError extends MenuSubcategoryState {
  final String message;
  const MenuSubcategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
