import 'package:equatable/equatable.dart';
import '../../domain/entities/table_info.dart';

sealed class TablePickerState extends Equatable {
  const TablePickerState();

  @override
  List<Object?> get props => [];
}

class TablePickerInitial extends TablePickerState {}

class TablePickerLoading extends TablePickerState {}

class TablePickerLoaded extends TablePickerState {
  final List<TableInfo> tables;

  const TablePickerLoaded({required this.tables});

  TablePickerLoaded copyWith({List<TableInfo>? tables}) {
    return TablePickerLoaded(tables: tables ?? this.tables);
  }

  @override
  List<Object?> get props => [tables];
}

class TablePickerError extends TablePickerState {
  final String message;

  const TablePickerError(this.message);

  @override
  List<Object?> get props => [message];
}
