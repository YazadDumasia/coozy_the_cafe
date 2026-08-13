class TableInfo {
  final int? id;
  final String? name;
  final String? colorValue;
  final int? sortOrderIndex;
  final int? nosOfChairs;
  final String? description;
  final String? categoryName;
  final bool isOccupied;
  final bool isReserved;

  const TableInfo({
    this.id,
    this.name,
    this.colorValue,
    this.sortOrderIndex,
    this.nosOfChairs,
    this.description,
    this.categoryName,
    this.isOccupied = false,
    this.isReserved = false,
  });

  TableInfo copyWith({
    int? id,
    String? name,
    String? colorValue,
    int? sortOrderIndex,
    int? nosOfChairs,
    String? description,
    String? categoryName,
    bool? isOccupied,
    bool? isReserved,
  }) {
    return TableInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      sortOrderIndex: sortOrderIndex ?? this.sortOrderIndex,
      nosOfChairs: nosOfChairs ?? this.nosOfChairs,
      description: description ?? this.description,
      categoryName: categoryName ?? this.categoryName,
      isOccupied: isOccupied ?? this.isOccupied,
      isReserved: isReserved ?? this.isReserved,
    );
  }
}
