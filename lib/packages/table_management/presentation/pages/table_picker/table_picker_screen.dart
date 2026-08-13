import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_info.dart';
import 'package:coozy_the_cafe/packages/table_management/presentation/cubit/table_picker_cubit.dart';
import 'package:coozy_the_cafe/packages/table_management/presentation/cubit/table_picker_state.dart';

class TablePickerScreen extends StatefulWidget {
  final Function(TableInfo)? onTableSelected;

  const TablePickerScreen({super.key, this.onTableSelected});

  @override
  State<TablePickerScreen> createState() => _TablePickerScreenState();
}

class _TablePickerScreenState extends State<TablePickerScreen> {
  TablePickerCubit? _createdCubit;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _createdCubit?.close();
    super.dispose();
  }

  void _handleTableTap(BuildContext context, TableInfo table) {
    if (table.isReserved) {
      _showReservedTableDialog(context, table);
    } else {
      _selectTable(table);
    }
  }

  void _selectTable(TableInfo table) {
    widget.onTableSelected?.call(table);
    Navigator.of(context).pop(table);
  }

  Future<void> _showReservedTableDialog(
    BuildContext context,
    TableInfo table,
  ) async {
    final titleText =
        context.tr(
          shared.LocaleKeys.commonAlertTitleText,
          track: shared.TrackConstants.tablePageTrack,
        ) ??
        'Table Reserved';
    final messageText =
        context.tr(
          shared.LocaleKeys.tableReservedConfirmationMsg,
          track: shared.TrackConstants.tablePageTrack,
        ) ??
        'Do you want to allow to place order on this table has been reserve';
    final cancelText =
        context.tr(
          shared.LocaleKeys.commonCancel,
          track: shared.TrackConstants.tablePageTrack,
        ) ??
        'Cancel';
    final allowText =
        context.tr(
          shared.LocaleKeys.allowPlaceOrder,
          track: shared.TrackConstants.tablePageTrack,
        ) ??
        'Allow';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            titleText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(messageText),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(allowText),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      _selectTable(table);
    }
  }

  @override
  Widget build(BuildContext context) {
    TablePickerCubit cubit;
    try {
      cubit = BlocProvider.of<TablePickerCubit>(context);
    } catch (_) {
      _createdCubit ??= GetIt.instance<TablePickerCubit>()..loadTables();
      cubit = _createdCubit!;
    }

    final primaryColor = Theme.of(context).primaryColor != Colors.blue
        ? Theme.of(context).primaryColor
        : const Color(0xFF673AB7);

    final appBarTitle =
        context.tr(
          shared.LocaleKeys.selectTableTitle,
          track: shared.TrackConstants.tablePageTrack,
        ) ??
        'SELECT TABLE';

    final defaultAllText =
        context.tr(
          shared.LocaleKeys.defaultAll,
          track: shared.TrackConstants.tablePageTrack,
        ) ??
        'DEFAULT ALL';

    return BlocProvider.value(
      value: cubit,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text(appBarTitle)),
          body: BlocBuilder<TablePickerCubit, TablePickerState>(
            builder: (context, state) {
              if (state is TablePickerLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<TableInfo> tables = [];
              List<String> categories = [defaultAllText];
              String selectedCategory = 'DEFAULT ALL';

              if (state is TablePickerLoaded) {
                tables = state.filteredTables;
                categories = state.categories;
                selectedCategory = state.selectedCategory;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Category / Filter Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      top: 12.0,
                      bottom: 8.0,
                      right: 12.0,
                    ),
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = cat == selectedCategory;
                        final displayCat = cat == 'DEFAULT ALL'
                            ? defaultAllText.toUpperCase()
                            : cat.toUpperCase();
                        return GestureDetector(
                          onTap: () {
                            context.read<TablePickerCubit>().selectCategory(cat);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              displayCat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Tables Grid View
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        if (constraints.maxWidth >= 1200) {
                          crossAxisCount = 5;
                        } else if (constraints.maxWidth >= 900) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 3;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(10.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 1.45,
                              ),
                          itemCount: tables.length,
                          itemBuilder: (context, index) {
                            final table = tables[index];
                            return _buildTableGridItem(
                              context,
                              table: table,
                              primaryColor: primaryColor,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTableGridItem(
    BuildContext context, {
    required TableInfo table,
    required Color primaryColor,
  }) {
    final String statusText;
    if (table.isOccupied) {
      statusText =
          context.tr(
            shared.LocaleKeys.occupiedStatus,
            track: shared.TrackConstants.tablePageTrack,
          ) ??
          'OCCUPIED';
    } else if (table.isReserved) {
      statusText =
          context.tr(
            shared.LocaleKeys.reservedStatus,
            track: shared.TrackConstants.tablePageTrack,
          ) ??
          'RESERVED';
    } else {
      statusText =
          context.tr(
            shared.LocaleKeys.emptyStatus,
            track: shared.TrackConstants.tablePageTrack,
          ) ??
          'EMPTY';
    }

    final headerBgColor = table.isOccupied
        ? primaryColor
        : const Color(0xFFE5E5E5);
    final headerTextColor = table.isOccupied ? Colors.white : Colors.black87;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      child: InkWell(
        onTap: () => _handleTableTap(context, table),
        borderRadius: BorderRadius.circular(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Header
            Container(
              color: headerBgColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10.0,
              ),
              child: Text(
                'TABLE - ${table.name?.toUpperCase() ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: headerTextColor,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Card Body
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      statusText.toUpperCase(),
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: table.isOccupied
                            ? primaryColor
                            : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (table.description != null &&
                        table.description!.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        table.description!,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
