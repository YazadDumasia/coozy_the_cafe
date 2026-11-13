part of 'menu_item_bloc.dart';

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
  final Map<int, Uint8List> prebuiltColumnsBarcodePdfBytes;
  final bool isPrebuildingBarcodePdf;

  const MenuItemLoaded({
    required this.items,
    this.categoryIdFilter,
    this.subcategoryIdFilter,
    this.prebuiltColumnsBarcodePdfBytes = const {},
    this.isPrebuildingBarcodePdf = false,
  });

  Uint8List? get prebuiltBarcodePdfBytes =>
      prebuiltColumnsBarcodePdfBytes[2] ?? prebuiltColumnsBarcodePdfBytes[3];

  MenuItemLoaded copyWith({
    List<MenuItem>? items,
    int? categoryIdFilter,
    int? subcategoryIdFilter,
    Map<int, Uint8List>? prebuiltColumnsBarcodePdfBytes,
    Uint8List? prebuiltBarcodePdfBytes,
    bool? isPrebuildingBarcodePdf,
    bool clearPrebuiltPdf = false,
  }) {
    Map<int, Uint8List> updatedMap;
    if (clearPrebuiltPdf) {
      updatedMap = const {};
    } else if (prebuiltColumnsBarcodePdfBytes != null) {
      updatedMap = prebuiltColumnsBarcodePdfBytes;
    } else if (prebuiltBarcodePdfBytes != null) {
      updatedMap = Map<int, Uint8List>.from(this.prebuiltColumnsBarcodePdfBytes)
        ..[2] = prebuiltBarcodePdfBytes;
    } else {
      updatedMap = this.prebuiltColumnsBarcodePdfBytes;
    }

    return MenuItemLoaded(
      items: items ?? this.items,
      categoryIdFilter: categoryIdFilter ?? this.categoryIdFilter,
      subcategoryIdFilter: subcategoryIdFilter ?? this.subcategoryIdFilter,
      prebuiltColumnsBarcodePdfBytes: updatedMap,
      isPrebuildingBarcodePdf:
          isPrebuildingBarcodePdf ?? this.isPrebuildingBarcodePdf,
    );
  }

  @override
  List<Object?> get props => [
    items,
    categoryIdFilter,
    subcategoryIdFilter,
    prebuiltColumnsBarcodePdfBytes,
    isPrebuildingBarcodePdf,
  ];
}

class MenuItemError extends MenuItemState {
  final String message;
  const MenuItemError(this.message);

  @override
  List<Object?> get props => [message];
}
