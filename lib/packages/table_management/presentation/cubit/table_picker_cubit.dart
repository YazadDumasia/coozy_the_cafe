import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/table_info.dart';
import '../../domain/usecases/get_tables_usecase.dart';
import 'table_picker_state.dart';

class TablePickerCubit extends Cubit<TablePickerState> {
  final GetTablesUseCase getTablesUseCase;

  TablePickerCubit({required this.getTablesUseCase})
    : super(TablePickerInitial());

  Future<void> loadTables() async {
    emit(TablePickerLoading());
    try {
      final tables = await getTablesUseCase();
      final effectiveTables = tables.isNotEmpty ? tables : _getFallbackTables();

      emit(TablePickerLoaded(tables: effectiveTables));
    } catch (e) {
      final fallback = _getFallbackTables();
      emit(TablePickerLoaded(tables: fallback));
    }
  }

  List<TableInfo> _filterTables(List<TableInfo> tables, String category) {
    if (category == 'DEFAULT ALL') {
      return tables;
    }
    return tables.where((t) => t.categoryName == category).toList();
  }

  }
}
