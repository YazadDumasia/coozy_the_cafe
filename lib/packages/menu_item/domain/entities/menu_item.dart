import 'package:equatable/equatable.dart';
import 'menu_item_variation.dart';

class MenuItem extends Equatable {
  final int? id;
  final String? hashId;
  final String name;
  final String? description;
  final String? foodType;
  final String? creationDate;
  final String? modificationDate;
  final int? duration;
  final int? categoryId;
  final int? subcategoryId;
  final bool? isTodayAvailable;
  final bool? isSimpleVariation;
  final double? costPrice;
  final double? sellingPrice;
  final double? stockQuantity;
  final String? quantity;
  final String? purchaseUnit;
  final int? sortOrderIndex;

  // The aggregate root contains its variations
  final List<MenuItemVariation> variations;

  const MenuItem({
    this.id,
    this.hashId,
    required this.name,
    required this.description,
    this.foodType,
    this.creationDate,
    this.modificationDate,
    this.duration,
    this.categoryId,
    this.subcategoryId,
    this.isTodayAvailable,
    this.isSimpleVariation,
    this.costPrice,
    this.sellingPrice,
    this.stockQuantity,
    this.quantity,
    this.purchaseUnit,
    this.sortOrderIndex,
    this.variations = const [],
  });

  MenuItem copyWith({
    int? id,
    String? hashId,
    String? name,
    String? description,
    String? foodType,
    String? creationDate,
    String? modificationDate,
    int? duration,
    int? categoryId,
    int? subcategoryId,
    bool? isTodayAvailable,
    bool? isSimpleVariation,
    double? costPrice,
    double? sellingPrice,
    double? stockQuantity,
    String? quantity,
    String? purchaseUnit,
    int? sortOrderIndex,
    List<MenuItemVariation>? variations,
  }) {
    return MenuItem(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      name: name ?? this.name,
      description: description ?? this.description,
      foodType: foodType ?? this.foodType,
      creationDate: creationDate ?? this.creationDate,
      modificationDate: modificationDate ?? this.modificationDate,
      duration: duration ?? this.duration,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      isTodayAvailable: isTodayAvailable ?? this.isTodayAvailable,
      isSimpleVariation: isSimpleVariation ?? this.isSimpleVariation,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      quantity: quantity ?? this.quantity,
      purchaseUnit: purchaseUnit ?? this.purchaseUnit,
      sortOrderIndex: sortOrderIndex ?? this.sortOrderIndex,
      variations: variations ?? this.variations,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    name,
    description,
    foodType,
    creationDate,
    modificationDate,
    duration,
    categoryId,
    subcategoryId,
    isTodayAvailable,
    isSimpleVariation,
    costPrice,
    sellingPrice,
    stockQuantity,
    quantity,
    purchaseUnit,
    sortOrderIndex,
    variations,
  ];
}
