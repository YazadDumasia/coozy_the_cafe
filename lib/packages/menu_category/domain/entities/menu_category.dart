class MenuCategory {
  final int? id;
  final String? hashId;
  final String? name;
  final bool? isActive;
  final int? position;
  final String? createdDate;

  const MenuCategory({
    this.id,
    this.hashId,
    this.name,
    this.isActive,
    this.position,
    this.createdDate,
  });

  MenuCategory copyWith({
    int? id,
    String? hashId,
    String? name,
    bool? isActive,
    int? position,
    String? createdDate,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      position: position ?? this.position,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
