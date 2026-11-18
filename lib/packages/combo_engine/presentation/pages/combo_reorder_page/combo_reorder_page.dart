import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../bloc/combo_bloc.dart';
import '../../../domain/entities/combo.dart';
import 'widget/combo_reorder_empty_view.dart';
import 'widget/combo_reorder_list_tile.dart';

class ComboReorderPage extends StatefulWidget {
  const ComboReorderPage({super.key});

  @override
  State<ComboReorderPage> createState() => _ComboReorderPageState();
}

class _ComboReorderPageState extends State<ComboReorderPage> {
  @override
  void initState() {
    super.initState();
    // Refresh active combo stream
    context.read<ComboBloc>().add(const LoadCombosEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
                shared.LocaleKeys.comboReorderPageAppbarTitle,
                track: shared.TrackConstants.comboPageTrack,
              ) ??
              'Reorder Combos',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<ComboBloc, ComboState>(
        listener: (context, state) {
          if (state is ComboErrorState) {
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

          if (combos.isEmpty) {
            return const ComboReorderEmptyView();
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instruction banner
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.secondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.swap_vert_rounded,
                          size: 20,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.tr(
                                  shared
                                      .LocaleKeys
                                      .comboReorderPageInstructionSubtitle,
                                  track: shared.TrackConstants.comboPageTrack,
                                ) ??
                                'Drag and reorder combos to customize their display sequence in the menu item picker.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reorderable list
                  Expanded(
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, _) {
                            final animValue = Curves.easeInOut.transform(
                              animation.value,
                            );
                            final elevation = animValue * 8.0;
                            final scale = 1.0 + (0.03 * animValue);
                            final combo = combos[index];

                            return Transform.scale(
                              scale: scale,
                              child: Material(
                                elevation: elevation,
                                shadowColor: colorScheme.shadow.withValues(
                                  alpha: 0.35,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.transparent,
                                child: ComboReorderListTile(
                                  combo: combo,
                                  displayIndex: index + 1,
                                  isDragging: true,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: combos.length,
                      onReorderItem: (oldIndex, newIndex) {
                        core.PlatformUtils.debugLog(
                          ComboReorderPage,
                          'Reordering from oldIndex=$oldIndex to newIndex=$newIndex',
                        );
                        context.read<ComboBloc>().add(
                          ReorderCombosEvent(
                            oldIndex: oldIndex,
                            newIndex: newIndex,
                          ),
                        );
                      },
                      itemBuilder: (context, index) {
                        final combo = combos[index];
                        return ComboReorderListTile(
                          key: ValueKey('combo_reorder_${combo.id ?? index}'),
                          combo: combo,
                          displayIndex: index + 1,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
