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

  const MenuSubcategoryLoaded({
    required this.subcategories,
    this.isReorderAllowed = false,
    this.categoryIdFilter,
  });

  MenuSubcategoryLoaded copyWith({
    List<MenuSubcategory>? subcategories,
    bool? isReorderAllowed,
    int? categoryIdFilter,
  }) {
    return MenuSubcategoryLoaded(
      subcategories: subcategories ?? this.subcategories,
      isReorderAllowed: isReorderAllowed ?? this.isReorderAllowed,
      categoryIdFilter: categoryIdFilter ?? this.categoryIdFilter,
    );
  }

  @override
  List<Object?> get props => [
    subcategories,
    isReorderAllowed,
    categoryIdFilter,
  ];
}

class MenuSubcategoryError extends MenuSubcategoryState {
  final String message;
  const MenuSubcategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
