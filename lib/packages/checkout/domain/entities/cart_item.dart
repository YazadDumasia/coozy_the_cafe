import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double itemDiscount;

  const CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.itemDiscount = 0.0,
  });

  double get lineTotal => (unitPrice * quantity) - itemDiscount;

  CartItem copyWith({
    String? id,
    String? name,
    int? quantity,
    double? unitPrice,
    double? itemDiscount,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      itemDiscount: itemDiscount ?? this.itemDiscount,
    );
  }

  @override
  List<Object?> get props => [id, name, quantity, unitPrice, itemDiscount];
}
