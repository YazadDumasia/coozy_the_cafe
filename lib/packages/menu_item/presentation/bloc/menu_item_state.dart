import 'package:equatable/equatable.dart';
import '../../domain/entities/menu_item.dart';

sealed class MenuItemState extends Equatable {
  const MenuItemState();

  @override
  List<Object?> get props => [];
}

class MenuItemInitial extends MenuItemState {}

class MenuItemLoading extends MenuItemState {}

class MenuItemLoaded extends MenuItemState {
  final List<MenuItem> items;
  final int? categoryIdFilter;
  final int? subcategoryIdFilter;

  const MenuItemLoaded({
    required this.items,
    this.categoryIdFilter,
    this.subcategoryIdFilter,
  });

  MenuItemLoaded copyWith({
    List<MenuItem>? items,
    int? categoryIdFilter,
    int? subcategoryIdFilter,
  }) {
    return MenuItemLoaded(
      items: items ?? this.items,
      categoryIdFilter: categoryIdFilter ?? this.categoryIdFilter,
      subcategoryIdFilter: subcategoryIdFilter ?? this.subcategoryIdFilter,
    );
  }

  @override
  List<Object?> get props => [items, categoryIdFilter, subcategoryIdFilter];
}

class MenuItemError extends MenuItemState {
  final String message;
  const MenuItemError(this.message);

  @override
  List<Object?> get props => [message];
}
