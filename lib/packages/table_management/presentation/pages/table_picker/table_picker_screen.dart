import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/table_entity.dart';
import '../../bloc/table_picker_bloc.dart';
import '../../widgets/table_picker/table_card_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TablePickerScreen extends StatelessWidget {
  final Function(TableEntity)? onTableSelected;

  const TablePickerScreen({super.key, this.onTableSelected});

  @override
  Widget build(BuildContext context) {
    const double iconSize = 110.0;
    return BlocProvider(
      create: (_) => sl<TablePickerBloc>()..add(const LoadTablesEvent()),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              context.tr(
                    shared.LocaleKeys.tablePickerTitle,
                    track: shared.TrackConstants.tablePageTrack,
                  ) ??
                  'Table Picker',
            ),
          ),
          body: BlocBuilder<TablePickerBloc, TablePickerState>(
            builder: (context, state) {
              if (state is TablePickerLoading || state is TablePickerInitial) {
                return const shared.LoadingPage();
              }

              if (state is TablePickerError) {
                return shared.ErrorPage(
                  onPressedRetryButton: () {
                    context.read<TablePickerBloc>().add(
                      const LoadTablesEvent(),
                    );
                  },
                );
              }

              if (state is! TablePickerLoaded) {
                return const SizedBox.shrink();
              }

              final tables = state.tables;
              if (tables.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        shared.MenuIcons.roundTable,
                        color: Theme.of(context).colorScheme.primary,
                        size: iconSize,
                      ),
                      SizedBox(height: 10),
                      Text(
                        context.tr(
                              shared.LocaleKeys.noTablesAvailable,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'No tables available',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ).inExpandedRow(),
                    ],
                  ),
                );
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
                    final isSelectable = table.status == TableStatus.empty;
                    return TableCardWidget(
                      table: table,
                      onTap: isSelectable
                          ? () => onTableSelected?.call(table)
                          : null,
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
