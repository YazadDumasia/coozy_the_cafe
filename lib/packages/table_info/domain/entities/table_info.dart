class TableInfo {
  final int? id;
  final String? name;
  final String? colorValue;
  final int? sortOrderIndex;
  final int? nosOfChairs;

  const TableInfo({
    this.id,
    this.name,
    this.colorValue,
    this.sortOrderIndex,
    this.nosOfChairs,
  });

  TableInfo copyWith({
    int? id,
    String? name,
    String? colorValue,
    int? sortOrderIndex,
    int? nosOfChairs,
  }) {
    return TableInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      sortOrderIndex: sortOrderIndex ?? this.sortOrderIndex,
      nosOfChairs: nosOfChairs ?? this.nosOfChairs,
    );
  }
}
