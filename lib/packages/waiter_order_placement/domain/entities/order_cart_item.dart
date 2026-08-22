import 'package:equatable/equatable.dart';

class OrderCartItem extends Equatable {
  final int menuItemId;
  final String name;
  final int? variationId;
  final String? variationName;
  final double price;
  final int quantity;
  final String? remarks;
  final int? subcategoryId;
  final String? subcategoryName;
  final int? categoryId;

  const OrderCartItem({
    required this.menuItemId,
    required this.name,
    this.variationId,
    this.variationName,
    required this.price,
    this.quantity = 1,
    this.remarks,
    this.subcategoryId,
    this.subcategoryName,
    this.categoryId,
  });

  OrderCartItem copyWith({
    int? menuItemId,
    String? name,
    int? variationId,
    String? variationName,
    double? price,
    int? quantity,
    String? remarks,
    int? subcategoryId,
    String? subcategoryName,
    int? categoryId,
  }) {
    return OrderCartItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      variationId: variationId ?? this.variationId,
      variationName: variationName ?? this.variationName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      remarks: remarks ?? this.remarks,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  double get totalPrice => price * quantity;

  String get displayName {
    if (variationName != null && variationName!.isNotEmpty) {
      return '$name ($variationName)';
    }
    return name;
  }

  @override
  List<Object?> get props => [
        menuItemId,
        name,
        variationId,
        variationName,
        price,
        quantity,
        remarks,
        subcategoryId,
        subcategoryName,
        categoryId,
      ];
}
