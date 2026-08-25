import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_entity.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/repositories/tables_repository.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/usecases/watch_tables_use_case.dart';
import 'package:coozy_the_cafe/packages/table_management/presentation/bloc/table_picker_bloc.dart';

class DummyTablesRepository implements TablesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeWatchTablesUseCase extends WatchTablesUseCase {
  final Stream<List<TableEntity>> stream;
  FakeWatchTablesUseCase(this.stream) : super(DummyTablesRepository());

  @override
  Stream<List<TableEntity>> call() => stream;
}

void main() {
  group('TablePickerBloc', () {
    test(
      'emits [TablePickerLoading, TablePickerLoaded] when LoadTablesEvent is added',
      () async {
        final controller = StreamController<List<TableEntity>>();
        final useCase = FakeWatchTablesUseCase(controller.stream);
        final bloc = TablePickerBloc(watchTablesUseCase: useCase);

        final expectedStates = <TablePickerState>[];
        final subscription = bloc.stream.listen(expectedStates.add);

        expect(bloc.state, isA<TablePickerInitial>());

        bloc.add(const LoadTablesEvent());
        await pumpEventQueue();

        const testTables = [
          TableEntity(
            id: 1,
            name: 'Table 1',
            tableNumber: '1',
            colorValue: null,
            sortOrderIndex: 1,
            nosOfChairs: 4,
            status: TableStatus.empty,
          ),
        ];

        controller.add(testTables);
        await pumpEventQueue();

        expect(expectedStates.length, 2);
        expect(expectedStates[0], isA<TablePickerLoading>());
        expect(expectedStates[1], isA<TablePickerLoaded>());
        expect((expectedStates[1] as TablePickerLoaded).tables, testTables);

        await subscription.cancel();
        await controller.close();
        await bloc.close();
      },
    );

    test(
      'emits [TablePickerLoading, TablePickerError] when stream emits error',
      () async {
        final controller = StreamController<List<TableEntity>>();
        final useCase = FakeWatchTablesUseCase(controller.stream);
        final bloc = TablePickerBloc(watchTablesUseCase: useCase);

        final expectedStates = <TablePickerState>[];
        final subscription = bloc.stream.listen(expectedStates.add);

        bloc.add(const LoadTablesEvent());
        await pumpEventQueue();

        controller.addError(Exception('Database error'));
        await pumpEventQueue();

        expect(expectedStates.length, 2);
        expect(expectedStates[0], isA<TablePickerLoading>());
        expect(expectedStates[1], isA<TablePickerError>());
        expect(
          (expectedStates[1] as TablePickerError).message,
          contains('Database error'),
        );

        await subscription.cancel();
        await controller.close();
        await bloc.close();
      },
    );
  });
}
