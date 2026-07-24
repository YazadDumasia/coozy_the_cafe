import 'package:equatable/equatable.dart';
import '../../domain/entities/table_info.dart';

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

  const TableLoaded({
    required this.tables,
    this.isGridView = true,
    this.isReorderAllowed = false,
  });

  TableLoaded copyWith({
    List<TableInfo>? tables,
    bool? isGridView,
    bool? isReorderAllowed,
  }) {
    return TableLoaded(
      tables: tables ?? this.tables,
      isGridView: isGridView ?? this.isGridView,
      isReorderAllowed: isReorderAllowed ?? this.isReorderAllowed,
    );
  }

  @override
  List<Object?> get props => [tables, isGridView, isReorderAllowed];
}

class TableError extends TableState {
  final String message;

  const TableError(this.message);

  @override
  List<Object?> get props => [message];
}
