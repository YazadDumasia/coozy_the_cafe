import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class MenuSubcategory implements shared.ISuspensionBean {
  final int? id;
  final String? hashId;
  final int? categoryId;
  final String? name;
  final bool? isActive;
  final int? position;
  final String? createdDate;

  @override
  bool isShowSuspension = false;

  MenuSubcategory({
    this.id,
    this.hashId,
    this.categoryId,
    this.name,
    this.isActive,
    this.position,
    this.createdDate,
    this.isShowSuspension = false,
  });

  @override
  String getSuspensionTag() {
    if (name != null && name!.isNotEmpty) {
      final tag = name![0].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(tag)) {
        return tag;
      }
    }
    return '#';
  }

  factory MenuSubcategory.fromJson(Map<String, dynamic> json) {
    final dynamic rawActive = json['isActive'];
    bool? isActive;
    if (rawActive is bool) {
      isActive = rawActive;
    } else if (rawActive is num) {
      isActive = rawActive == 1;
    }
    return MenuSubcategory(
      id: json['id'] as int?,
      hashId: json['hashId'] as String?,
      categoryId: json['categoryId'] as int?,
      name: json['name'] as String?,
      isActive: isActive,
      position: json['position'] as int?,
      createdDate: json['createdDate'] as String?,
    );
  }

  MenuSubcategory copyWith({
    int? id,
    String? hashId,
    int? categoryId,
    String? name,
    bool? isActive,
    int? position,
    String? createdDate,
  }) {
    return MenuSubcategory(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      position: position ?? this.position,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

