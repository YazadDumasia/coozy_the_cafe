part of 'table_picker_bloc.dart';

sealed class TablePickerEvent extends Equatable {
  const TablePickerEvent();

  @override
  List<Object?> get props => [];
}

class LoadTablesEvent extends TablePickerEvent {
  const LoadTablesEvent();
}
