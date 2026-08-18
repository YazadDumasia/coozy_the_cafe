import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/table_picker_dao.dart';
import '../../../data/repositories/tables_repository_impl.dart';
import '../../../domain/entities/table_entity.dart';
import '../../../domain/usecases/watch_tables_use_case.dart';
import '../../bloc/table_picker_bloc.dart';
import '../../widgets/table_picker/table_card_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TablePickerScreen extends StatelessWidget {
  final Function(TableEntity)? onTableSelected;

  const TablePickerScreen({super.key, this.onTableSelected});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final db = CoozyDatabase();
        final dao = TablePickerDao(db);
        final repository = TablesRepositoryImpl(tablePickerDao: dao);
        final useCase = WatchTablesUseCase(repository);
        return TablePickerBloc(watchTablesUseCase: useCase)
          ..add(const LoadTablesEvent());
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: const Text('Table Picker')),
          body: BlocBuilder<TablePickerBloc, TablePickerState>(
            builder: (context, state) {
              if (state is TablePickerLoading || state is TablePickerInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TablePickerError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(state.message, textAlign: TextAlign.center),
                  ),
                );
              }

              if (state is! TablePickerLoaded) {
                return const SizedBox.shrink();
              }

              final tables = state.tables;
              if (tables.isEmpty) {
                return const Center(child: Text('No tables available'));
              }
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: MasonryGridView.builder(
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns
                      ),
                  itemCount: tables.length,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemBuilder: (context, index) {
                    final table = tables[index];
                    return TableCardWidget(
                      table: table,
                      onTap: () => onTableSelected?.call(table),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
