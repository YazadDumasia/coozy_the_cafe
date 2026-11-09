import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item_variation.dart';

class ComboItem extends Equatable {
  final int? id;
  final String? hashId;
  final int comboId;
  final int menuItemId;
  final int? variationId;
  final int quantity;
  final MenuItem? menuItem;
  final MenuItemVariation? variation;

  const ComboItem({
    this.id,
    this.hashId,
    required this.comboId,
    required this.menuItemId,
    this.variationId,
    this.quantity = 1,
    this.menuItem,
    this.variation,
  });

  double get unitPrice {
    if (variation != null && variation!.sellingPrice != null) {
      return variation!.sellingPrice!;
    }
    return menuItem?.sellingPrice ?? 0.0;
  }

  double get totalPrice => unitPrice * quantity;

  /// Effective duration in seconds for this item/variation
  int? get duration {
    if (variation != null &&
        variation!.duration != null &&
        variation!.duration! > 0) {
      return variation!.duration;
    }
    return menuItem?.duration;
  }

  ComboItem copyWith({
    int? id,
    String? hashId,
    int? comboId,
    int? menuItemId,
    int? variationId,
    int? quantity,
    MenuItem? menuItem,
    MenuItemVariation? variation,
  }) {
    return ComboItem(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      comboId: comboId ?? this.comboId,
      menuItemId: menuItemId ?? this.menuItemId,
      variationId: variationId ?? this.variationId,
      quantity: quantity ?? this.quantity,
      menuItem: menuItem ?? this.menuItem,
      variation: variation ?? this.variation,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    comboId,
    menuItemId,
    variationId,
    quantity,
    menuItem,
    variation,
  ];
}
