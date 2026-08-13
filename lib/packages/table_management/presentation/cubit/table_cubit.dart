import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/table_info.dart';
import '../../domain/usecases/add_table_usecase.dart';
import '../../domain/usecases/delete_table_usecase.dart';
import '../../domain/usecases/get_tables_usecase.dart';
import '../../domain/usecases/update_table_usecase.dart';
import '../../domain/usecases/update_table_sort_orders_usecase.dart';
import 'table_state.dart';

class TableCubit extends Cubit<TableState> {
  final GetTablesUseCase getTablesUseCase;
  final AddTableUseCase addTableUseCase;
  final UpdateTableUseCase updateTableUseCase;
  final DeleteTableUseCase deleteTableUseCase;
  final UpdateTableSortOrdersUseCase updateTableSortOrdersUseCase;

  TableCubit({
    required this.getTablesUseCase,
    required this.addTableUseCase,
    required this.updateTableUseCase,
    required this.deleteTableUseCase,
    required this.updateTableSortOrdersUseCase,
  }) : super(TableInitial());

  Future<void> loadTables({bool isSilent = false}) async {
    bool currentGridView = true;
    bool currentReorderAllowed = false;

    if (state is TableLoaded) {
      currentGridView = (state as TableLoaded).isGridView;
      currentReorderAllowed = (state as TableLoaded).isReorderAllowed;
    }

    if (!isSilent) emit(TableLoading());
    try {
      final tables = await getTablesUseCase();
      emit(
        TableLoaded(
          tables: tables,
          isGridView: currentGridView,
          isReorderAllowed: currentReorderAllowed,
        ),
      );
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  void toggleView() {
    if (state is TableLoaded) {
      final currentState = state as TableLoaded;
      emit(currentState.copyWith(isGridView: !currentState.isGridView));
    }
  }

  void toggleReorder() {
    if (state is TableLoaded) {
      final currentState = state as TableLoaded;
      emit(
        currentState.copyWith(isReorderAllowed: !currentState.isReorderAllowed),
      );
    }
  }

  Future<void> addTable(
    TableInfo table, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      await addTableUseCase(table);
      await loadTables(isSilent: true);
      onSuccess?.call();
    } catch (e) {
      // Re-emit error or handle it
      final currentState = state;
      emit(TableError(e.toString()));
      if (currentState is TableLoaded) {
        emit(currentState);
      }
      onError?.call(e.toString());
    }
  }

  Future<void> updateTable(
    TableInfo table, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      await updateTableUseCase(table);
      await loadTables(isSilent: true);
      onSuccess?.call();
    } catch (e) {
      final currentState = state;
      emit(TableError(e.toString()));
      if (currentState is TableLoaded) {
        emit(currentState);
      }
      onError?.call(e.toString());
    }
  }

  Future<void> deleteTable(
    int tableId, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      await deleteTableUseCase(tableId);
      await loadTables(isSilent: true);
      onSuccess?.call();
    } catch (e) {
      final currentState = state;
      emit(TableError(e.toString()));
      if (currentState is TableLoaded) {
        emit(currentState);
      }
      onError?.call(e.toString());
    }
  }

  Future<void> reorderTables(int oldIndex, int newIndex) async {
    if (state is TableLoaded) {
      final currentState = state as TableLoaded;
      final list = List<TableInfo>.from(currentState.tables);

      int actualNewIndex = newIndex;
      if (actualNewIndex > oldIndex) {
        actualNewIndex -= 1;
      }

      final item = list.removeAt(oldIndex);
      list.insert(actualNewIndex, item);

      // Optimistically update UI
      emit(currentState.copyWith(tables: list));

      // Update sort order for all affected items
      try {
        final List<TableInfo> updatedList = [];
        for (
          int i = min(oldIndex, actualNewIndex);
          i <= max(oldIndex, actualNewIndex);
          i++
        ) {
          updatedList.add(list[i].copyWith(sortOrderIndex: i));
        }
        await updateTableSortOrdersUseCase(updatedList);
        await loadTables(isSilent: true); // Reload to get fresh data from DB
      } catch (e) {
        emit(TableError('Failed to reorder tables'));
        emit(currentState); // Revert to old state
      }
    }
  }
}
