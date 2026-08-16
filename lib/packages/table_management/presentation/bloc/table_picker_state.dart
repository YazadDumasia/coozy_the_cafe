part of 'table_picker_bloc.dart';

sealed class TablePickerState extends Equatable {
  const TablePickerState();

  @override
  List<Object?> get props => [];
}

class TablePickerInitial extends TablePickerState {}

class TablePickerLoading extends TablePickerState {}

class TablePickerLoaded extends TablePickerState {
  final List<TableEntity> tables;

  const TablePickerLoaded({required this.tables});

  TablePickerLoaded copyWith({List<TableEntity>? tables}) {
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
