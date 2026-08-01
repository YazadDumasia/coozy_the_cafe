import 'package:equatable/equatable.dart';
import '../../domain/entities/menu_subcategory.dart';

sealed class MenuSubcategoryState extends Equatable {
  const MenuSubcategoryState();

  @override
  List<Object?> get props => [];
}

class MenuSubcategoryInitial extends MenuSubcategoryState {}

class MenuSubcategoryLoading extends MenuSubcategoryState {}

class MenuSubcategoryLoaded extends MenuSubcategoryState {
  final List<MenuSubcategory> subcategories;
  final bool isReorderAllowed;
  final int? categoryIdFilter;
  final bool isSearchActive;

  const MenuSubcategoryLoaded({
    required this.subcategories,
    this.isReorderAllowed = false,
    this.categoryIdFilter,
    this.isSearchActive = false,
  });

  MenuSubcategoryLoaded copyWith({
    List<MenuSubcategory>? subcategories,
    bool? isReorderAllowed,
    int? categoryIdFilter,
    bool? isSearchActive,
  }) {
    return MenuSubcategoryLoaded(
      subcategories: subcategories ?? this.subcategories,
      isReorderAllowed: isReorderAllowed ?? this.isReorderAllowed,
      categoryIdFilter: categoryIdFilter ?? this.categoryIdFilter,
      isSearchActive: isSearchActive ?? this.isSearchActive,
    );
  }

  @override
  List<Object?> get props => [
    subcategories,
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
