import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/table_entity.dart';
import '../../domain/usecases/watch_tables_use_case.dart';

part 'table_picker_event.dart';
part 'table_picker_state.dart';

class TablePickerBloc extends Bloc<TablePickerEvent, TablePickerState> {
  final WatchTablesUseCase watchTablesUseCase;

  TablePickerBloc({required this.watchTablesUseCase})
    : super(TablePickerInitial()) {
    on<LoadTablesEvent>((event, emit) async {
      emit(TablePickerLoading());
      await emit.forEach<List<TableEntity>>(
        watchTablesUseCase(),
        onData: (tables) => TablePickerLoaded(tables: tables),
        onError: (error, stackTrace) => TablePickerError(error.toString()),
      );
    });
  }
}
