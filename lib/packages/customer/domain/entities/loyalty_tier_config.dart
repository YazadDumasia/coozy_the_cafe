import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Configuration model for a Loyalty Tier containing name, minimum points threshold, and color.
class LoyaltyTierConfig extends Equatable {
  const LoyaltyTierConfig({
    required this.name,
    this.minPoints = 0,
    this.colorHex = '#CD7F32', // default bronze
  });

  static const String defaultCustomTierColorHex = '#8D6E63'; // Custom tier default warm brown
  static const Color defaultCustomTierColor = Color(0xFF8D6E63);

  static const List<Color> selectableColors = [
    Color(0xFFCD7F32), // Bronze
    Color(0xFF607D8B), // Silver / BlueGrey
    Color(0xFFFFA000), // Amber / Gold
    Color(0xFF9C27B0), // Purple / VIP
    Color(0xFF2196F3), // Blue / Sapphire
    Color(0xFF4CAF50), // Green / Emerald
    Color(0xFFE91E63), // Pink / Ruby
    Color(0xFF00BCD4), // Cyan / Diamond
  ];

  final String name;
  final int minPoints;
  final String colorHex;

  static String colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static Color hexToColor(String? colorHex, {Color defaultColor = const Color(0xFFCD7F32)}) {
    if (colorHex == null || colorHex.trim().isEmpty) return defaultColor;
    final hex = colorHex.replaceAll('#', '').trim();
    if (hex.length == 6) {
      final val = int.tryParse('FF$hex', radix: 16);
      if (val != null) return Color(val);
    } else if (hex.length == 8) {
      final val = int.tryParse(hex, radix: 16);
      if (val != null) return Color(val);
    }
    return defaultColor;
  }

  Color get color => hexToColor(colorHex);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'minPoints': minPoints,
      'colorHex': colorHex,
    };
  }

  factory LoyaltyTierConfig.fromMap(Map<String, dynamic> map) {
    return LoyaltyTierConfig(
      name: (map['name'] as String?) ?? 'Tier',
      minPoints: (map['minPoints'] as num?)?.toInt() ?? 0,
      colorHex: (map['colorHex'] as String?) ?? '#CD7F32',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LoyaltyTierConfig.fromJson(String source) =>
      LoyaltyTierConfig.fromMap(jsonDecode(source) as Map<String, dynamic>);

  static List<LoyaltyTierConfig> defaultPrebuiltList() {
    return const [
      LoyaltyTierConfig(
        name: 'Bronze',
        minPoints: 0,
        colorHex: '#CD7F32',
      ),
      LoyaltyTierConfig(
        name: 'Silver',
        minPoints: 500,
        colorHex: '#607D8B',
      ),
      LoyaltyTierConfig(
        name: 'Gold',
        minPoints: 1000,
        colorHex: '#FFA000',
      ),
      LoyaltyTierConfig(
        name: 'VIP',
        minPoints: 2000,
        colorHex: '#9C27B0',
      ),
    ];
  }

  static String encodeList(List<LoyaltyTierConfig> list) {
    return jsonEncode(list.map((e) => e.toMap()).toList());
  }

  static List<LoyaltyTierConfig> decodeList(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) {
      return defaultPrebuiltList();
    }
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded
            .map((item) => LoyaltyTierConfig.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return defaultPrebuiltList();
  }

  LoyaltyTierConfig copyWith({
    String? name,
    int? minPoints,
    String? colorHex,
  }) {
    return LoyaltyTierConfig(
      name: name ?? this.name,
      minPoints: minPoints ?? this.minPoints,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [name, minPoints, colorHex];
}
