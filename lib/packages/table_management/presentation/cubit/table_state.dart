part of 'table_cubit.dart';

sealed class TableState extends Equatable {
  const TableState();

  @override
  List<Object?> get props => [];
}

class TableInitial extends TableState {}

class TableLoading extends TableState {}

class TableLoaded extends TableState {
  final List<TableInfo> tables;
  final bool isGridView;
  final bool isReorderAllowed;
  final Map<int, Uint8List> prebuiltColumnsPdfBytes;
  final bool isPrebuildingPdf;

  const TableLoaded({
    required this.tables,
    this.isGridView = true,
    this.isReorderAllowed = false,
    this.prebuiltColumnsPdfBytes = const {},
    this.isPrebuildingPdf = false,
  });

  Uint8List? get prebuiltPdfBytes => prebuiltColumnsPdfBytes[2];

  TableLoaded copyWith({
    List<TableInfo>? tables,
    bool? isGridView,
    bool? isReorderAllowed,
    Map<int, Uint8List>? prebuiltColumnsPdfBytes,
    Uint8List? prebuiltPdfBytes,
    bool? isPrebuildingPdf,
    bool clearPrebuiltPdf = false,
  }) {
    Map<int, Uint8List> updatedMap;
    if (clearPrebuiltPdf) {
      updatedMap = const {};
    } else if (prebuiltColumnsPdfBytes != null) {
      updatedMap = prebuiltColumnsPdfBytes;
    } else if (prebuiltPdfBytes != null) {
      updatedMap = Map<int, Uint8List>.from(this.prebuiltColumnsPdfBytes)
        ..[2] = prebuiltPdfBytes;
    } else {
      updatedMap = this.prebuiltColumnsPdfBytes;
    }

    return TableLoaded(
      tables: tables ?? this.tables,
      isGridView: isGridView ?? this.isGridView,
      isReorderAllowed: isReorderAllowed ?? this.isReorderAllowed,
      prebuiltColumnsPdfBytes: updatedMap,
      isPrebuildingPdf: isPrebuildingPdf ?? this.isPrebuildingPdf,
    );
  }

  @override
  List<Object?> get props => [
    tables,
    isGridView,
    isReorderAllowed,
    prebuiltColumnsPdfBytes,
    isPrebuildingPdf,
  ];
}

class TableError extends TableState {
  final String message;

  const TableError(this.message);

  @override
  List<Object?> get props => [message];
}
