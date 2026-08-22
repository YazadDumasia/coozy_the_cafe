class TableInfo {
  final int? id;
  final String? tableLabel;
  final String? tableNo;
  final String? colorValue;
  final int? sortOrderIndex;
  final int? nosOfChairs;
  final String? description;
  final String? categoryName;
  final bool isOccupied;
  final bool isReserved;
  final bool? isActive;

  const TableInfo({
    this.id,
    this.tableLabel,
    this.tableNo,
    this.colorValue,
    this.sortOrderIndex,
    this.nosOfChairs,
    this.description,
    this.categoryName,
    this.isOccupied = false,
    this.isReserved = false,
    this.isActive = true,
  });

  TableInfo copyWith({
    int? id,
    String? tableLabel,
    String? tableNo,
    String? colorValue,
    int? sortOrderIndex,
    int? nosOfChairs,
    String? description,
    String? categoryName,
    bool? isOccupied,
    bool? isReserved,
    bool? isActive,
  }) {
    return TableInfo(
      id: id ?? this.id,
      tableLabel: tableLabel ?? this.tableLabel,
      tableNo: tableNo ?? this.tableNo,
      colorValue: colorValue ?? this.colorValue,
      sortOrderIndex: sortOrderIndex ?? this.sortOrderIndex,
      nosOfChairs: nosOfChairs ?? this.nosOfChairs,
      description: description ?? this.description,
      categoryName: categoryName ?? this.categoryName,
      isOccupied: isOccupied ?? this.isOccupied,
      isReserved: isReserved ?? this.isReserved,
      isActive: isActive ?? this.isActive,
    );
  }
}
