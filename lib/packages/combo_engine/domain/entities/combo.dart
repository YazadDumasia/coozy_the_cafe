import 'package:equatable/equatable.dart';

import 'combo_item.dart';

class Combo extends Equatable {
  final int? id;
  final String? hashId;
  final String name;
  final String? description;
  final double originalPrice;
  final double sellingPrice;
  final int? duration;
  final bool isActive;
  final int? sortOrderIndex;
  final String? creationDate;
  final String? modificationDate;
  final List<ComboItem> items;

  const Combo({
    this.id,
    this.hashId,
    required this.name,
    this.description,
    this.originalPrice = 0.0,
    this.sellingPrice = 0.0,
    this.duration,
    this.isActive = true,
    this.sortOrderIndex,
    this.creationDate,
    this.modificationDate,
    this.items = const [],
  });

  /// Returns custom duration if set, otherwise the max duration among bundled items
  int? get effectiveDuration {
    if (duration != null && duration! > 0) return duration;
    if (items.isEmpty) return null;
    int maxDuration = 0;
    for (final item in items) {
      final itemDur = item.duration;
      if (itemDur != null && itemDur > maxDuration) {
        maxDuration = itemDur;
      }
    }
    return maxDuration > 0 ? maxDuration : null;
  }

  double get calculatedOriginalPrice {
    if (items.isEmpty) return originalPrice;
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get discountAmount {
    final orig = calculatedOriginalPrice;
    if (orig > sellingPrice) {
      return orig - sellingPrice;
    }
    return 0.0;
  }

  double get discountPercentage {
    final orig = calculatedOriginalPrice;
    if (orig <= 0 || sellingPrice >= orig) return 0.0;
    return ((orig - sellingPrice) / orig) * 100;
  }

  Combo copyWith({
    int? id,
    String? hashId,
    String? name,
    String? description,
    double? originalPrice,
    double? sellingPrice,
    int? duration,
    bool? isActive,
    int? sortOrderIndex,
    String? creationDate,
    String? modificationDate,
    List<ComboItem>? items,
  }) {
    return Combo(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      name: name ?? this.name,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      sortOrderIndex: sortOrderIndex ?? this.sortOrderIndex,
      creationDate: creationDate ?? this.creationDate,
      modificationDate: modificationDate ?? this.modificationDate,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    name,
    description,
    originalPrice,
    sellingPrice,
    duration,
    isActive,
    sortOrderIndex,
    creationDate,
    modificationDate,
    items,
  ];
}
