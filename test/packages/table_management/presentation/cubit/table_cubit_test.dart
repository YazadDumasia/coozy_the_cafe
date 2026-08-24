import 'package:flutter_test/flutter_test.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_info.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/repositories/table_repository.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/usecases/add_table_usecase.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/usecases/delete_table_usecase.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/usecases/get_tables_usecase.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/usecases/update_table_usecase.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/usecases/update_table_sort_orders_usecase.dart';
import 'package:coozy_the_cafe/packages/table_management/presentation/cubit/table_cubit.dart';

class DummyTableRepository implements TableRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetTablesUseCase extends GetTablesUseCase {
  List<TableInfo> tables;
  FakeGetTablesUseCase(this.tables) : super(DummyTableRepository());

  @override
  Future<List<TableInfo>> call() async => tables;
}

class FakeAddTableUseCase extends AddTableUseCase {
  FakeAddTableUseCase() : super(DummyTableRepository());
}

class FakeUpdateTableUseCase extends UpdateTableUseCase {
  FakeUpdateTableUseCase() : super(DummyTableRepository());
}

class FakeDeleteTableUseCase extends DeleteTableUseCase {
  FakeDeleteTableUseCase() : super(DummyTableRepository());
}

class FakeUpdateTableSortOrdersUseCase extends UpdateTableSortOrdersUseCase {
  final FakeGetTablesUseCase getTablesUseCase;

  FakeUpdateTableSortOrdersUseCase(this.getTablesUseCase) : super(DummyTableRepository());

  @override
  Future<void> call(List<TableInfo> updatedTables) async {
    final currentTables = Map<int, TableInfo>.fromEntries(
      getTablesUseCase.tables.map((t) => MapEntry(t.id!, t)),
    );
    for (final updated in updatedTables) {
      currentTables[updated.id!] = updated;
    }
    final newList = currentTables.values.toList()
      ..sort((a, b) => (a.sortOrderIndex ?? 0).compareTo(b.sortOrderIndex ?? 0));
    getTablesUseCase.tables = newList;
  }
}

void main() {
  late TableCubit tableCubit;
  late FakeGetTablesUseCase fakeGetTablesUseCase;
  late FakeUpdateTableSortOrdersUseCase fakeUpdateTableSortOrdersUseCase;

  final initialTables = List.generate(
    12,
    (index) => TableInfo(
      id: index + 1,
      tableLabel: 'Table ${index + 1}',
      sortOrderIndex: index,
    ),
  );

  setUp(() {
    fakeGetTablesUseCase = FakeGetTablesUseCase(List.from(initialTables));
    fakeUpdateTableSortOrdersUseCase = FakeUpdateTableSortOrdersUseCase(fakeGetTablesUseCase);

    tableCubit = TableCubit(
      getTablesUseCase: fakeGetTablesUseCase,
      addTableUseCase: FakeAddTableUseCase(),
      updateTableUseCase: FakeUpdateTableUseCase(),
      deleteTableUseCase: FakeDeleteTableUseCase(),
      updateTableSortOrdersUseCase: fakeUpdateTableSortOrdersUseCase,
    );
  });

  test('reorderTables places item at last position when dragged from index 1 to 11', () async {
    // Load initial tables into state
    await tableCubit.loadTables();

    expect(tableCubit.state, isA<TableLoaded>());
    final loadedStateBefore = tableCubit.state as TableLoaded;
    expect(loadedStateBefore.tables.length, 12);
    expect(loadedStateBefore.tables[1].id, 2);

    // Reorder second item (index 1) to very last position (index 11)
    await tableCubit.reorderTables(1, 11);

    expect(tableCubit.state, isA<TableLoaded>());
    final loadedStateAfter = tableCubit.state as TableLoaded;

    // The item with id 2 (originally at index 1) should now be at index 11 (last position)
    expect(loadedStateAfter.tables.last.id, 2);
    expect(loadedStateAfter.tables[11].id, 2);
    expect(loadedStateAfter.tables[10].id, 12);
  });
}
