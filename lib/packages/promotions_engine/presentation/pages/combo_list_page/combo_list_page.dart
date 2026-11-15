import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../domain/entities/combo.dart';
import '../../../domain/usecases/combo_usecases.dart';
import '../../bloc/combo_bloc.dart';
import '../combo_form_dialog/combo_form_dialog.dart';
import 'widget/combo_list_card.dart';
import 'widget/combo_list_empty_view.dart';

class ComboListPage extends StatefulWidget {
  final SearchMenuItemsForComboUseCase searchUseCase;
  final GetMenuItemsCountForComboUseCase countUseCase;

  const ComboListPage({
    super.key,
    required this.searchUseCase,
    required this.countUseCase,
  });

  @override
  State<ComboListPage> createState() => _ComboListPageState();
}

class _ComboListPageState extends State<ComboListPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<ComboBloc>().add(const LoadCombosEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openComboDialog([Combo? combo]) {
    PlatformUtils.debugLog(
      ComboListPage,
      '_openComboDialog: editingCombo=${combo?.name} (id: ${combo?.id})',
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ComboFormDialog(
        initialCombo: combo,
        searchUseCase: widget.searchUseCase,
        countUseCase: widget.countUseCase,
        onSave: (savedCombo) {
          PlatformUtils.debugLog(
            ComboListPage,
            '_openComboDialog.onSave: dispatching SaveComboEvent for "${savedCombo.name}"',
          );
          context.read<ComboBloc>().add(SaveComboEvent(savedCombo));
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    PlatformUtils.debugLog(
      ComboListPage,
      '_onSearchChanged: search query="$query"',
    );
    context.read<ComboBloc>().add(
      LoadCombosEvent(searchQuery: query.trim().isEmpty ? null : query.trim()),
    );
  }

  void _onDeleteCombo(Combo combo) {
    PlatformUtils.debugLog(
      ComboListPage,
      '_onDeleteCombo: prompt delete confirmation for "${combo.name}" (id: ${combo.id})',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Combo'),
        content: Text('Are you sure you want to delete "${combo.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (combo.id != null) {
                PlatformUtils.debugLog(
                  ComboListPage,
                  '_onDeleteCombo: confirmed, dispatching DeleteComboEvent for id=${combo.id}',
                );
                context.read<ComboBloc>().add(DeleteComboEvent(combo.id!));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Combos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => _openComboDialog(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Combo'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocConsumer<ComboBloc, ComboState>(
        listener: (context, state) {
          if (state is ComboActionSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ComboErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ComboLoadingState) {
            return const shared.LoadingPage();
          }

          if (state is ComboErrorState) {
            return shared.ErrorPage(
              errorMsg: state.errorMessage,
              onPressedRetryButton: () {
                context.read<ComboBloc>().add(const LoadCombosEvent());
              },
            );
          }

          final combos = state is ComboLoadedState ? state.combos : <Combo>[];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search combos by name or description...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              Expanded(
                child: combos.isEmpty
                    ? ComboListEmptyView(onAddNew: () => _openComboDialog())
                    : (isDesktop || isTablet)
                    ? MasonryGridView.count(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        crossAxisCount: isDesktop ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        itemCount: combos.length,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        itemBuilder: (context, index) {
                          final combo = combos[index];
                          return ComboListCard(
                            combo: combo,
                            onEdit: () => _openComboDialog(combo),
                            onDelete: () => _onDeleteCombo(combo),
                            onToggleStatus: (isActive) {
                              if (combo.id != null) {
                                context.read<ComboBloc>().add(
                                  ToggleComboStatusEvent(
                                    id: combo.id!,
                                    isActive: isActive,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemCount: combos.length,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        itemBuilder: (context, index) {
                          final combo = combos[index];
                          return ComboListCard(
                            combo: combo,
                            onEdit: () => _openComboDialog(combo),
                            onDelete: () => _onDeleteCombo(combo),
                            onToggleStatus: (isActive) {
                              if (combo.id != null) {
                                context.read<ComboBloc>().add(
                                  ToggleComboStatusEvent(
                                    id: combo.id!,
                                    isActive: isActive,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
