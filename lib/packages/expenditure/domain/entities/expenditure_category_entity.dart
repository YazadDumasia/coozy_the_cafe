import 'package:equatable/equatable.dart';

class ExpenditureCategoryEntity extends Equatable {
  final int? id;
  final String? hashId;
  final String name;
  final String type; // 'EXPENSE' or 'INCOME'
  final int? iconCodePoint;
  final String? iconFontFamily;
  final String? colorHex;
  final bool isCustom;
  final bool isEnabled;
  final String? createdAt;

  const ExpenditureCategoryEntity({
    this.id,
    this.hashId,
    required this.name,
    required this.type,
    this.iconCodePoint,
    this.iconFontFamily,
    this.colorHex,
    this.isCustom = false,
    this.isEnabled = true,
    this.createdAt,
  });

  ExpenditureCategoryEntity copyWith({
    int? id,
    String? hashId,
    String? name,
    String? type,
    int? iconCodePoint,
    String? iconFontFamily,
    String? colorHex,
    bool? isCustom,
    bool? isEnabled,
    String? createdAt,
  }) {
    return ExpenditureCategoryEntity(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      colorHex: colorHex ?? this.colorHex,
      isCustom: isCustom ?? this.isCustom,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    name,
    type,
    iconCodePoint,
    iconFontFamily,
    colorHex,
    isCustom,
    isEnabled,
    createdAt,
  ];
}
