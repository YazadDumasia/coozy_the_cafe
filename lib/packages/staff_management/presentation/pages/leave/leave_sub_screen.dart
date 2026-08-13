import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/leave/leave_bloc.dart';
import '../../bloc/leave/leave_event_state.dart';
import '../../../domain/entities/staff_entities.dart';
import '../../widgets/leave/leave_card.dart';
import '../../widgets/leave/leave_empty_view.dart';
import '../../widgets/leave/leave_form_dialog.dart';
import '../../widgets/common/staff_search_bar.dart';
import '../staff_management/staff_management_screen_actions.dart';

class LeaveSubScreen extends StatefulWidget {
  const LeaveSubScreen({super.key});

  @override
  State<LeaveSubScreen> createState() => _LeaveSubScreenState();
}

class _LeaveSubScreenState extends State<LeaveSubScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier<DateTime>(
    DateTime.now(),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(LoadLeavesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    _scrollController.dispose();
    _selectedDateNotifier.dispose();
    super.dispose();
  }

  void _showLeaveDialog(BuildContext context, {LeaveEntity? leave}) {
    LeaveFormDialog.show(
      context,
      leave: leave,
      onSubmit: (entity) {
        if (leave == null) {
          context.read<LeaveBloc>().add(
            AddLeaveEvent(
              entity,
              onSuccess: () => StaffManagementActions.showSuccessDialog(
                context,
                context.tr(
                      shared.LocaleKeys.leaveAppliedSuccess,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Leave applied successfully.',
              ),
              onError: (err) =>
                  StaffManagementActions.showErrorDialog(context, err),
            ),
          );
        } else {
          context.read<LeaveBloc>().add(
            UpdateLeaveEvent(
              entity,
              onSuccess: () => StaffManagementActions.showSuccessDialog(
                context,
                context.tr(
                      shared.LocaleKeys.leaveUpdatedSuccess,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Leave record updated successfully.',
              ),
              onError: (err) =>
                  StaffManagementActions.showErrorDialog(context, err),
            ),
          );
        }
      },
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Icon(
                Icons.info_outline,
                size: 36,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr(
                        shared.LocaleKeys.deleteConfirmTitle,
                        track: shared.TrackConstants.staffManagementPageTrack,
                      ) ??
                      'Are you sure ?',
                ),
              ),
            ],
          ),
          content: Text(
            context.tr(
                  shared.LocaleKeys.deleteLeaveConfirmMsg,
                  track: shared.TrackConstants.staffManagementPageTrack,
                ) ??
                'Do you really want to delete this leave information? You will not be able to undo this action.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonCancel,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _handleDelete(context, id);
              },
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonOkay,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Okay',
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDelete(BuildContext context, int id) {
    context.read<LeaveBloc>().add(
      DeleteLeaveEvent(
        id,
        onSuccess: () => StaffManagementActions.showSuccessDialog(
          context,
          context.tr(
                shared.LocaleKeys.leaveDeletedSuccess,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Leave record deleted successfully.',
        ),
        onError: (err) => StaffManagementActions.showErrorDialog(context, err),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final DateTime now = DateTime.now();
    final DateTime startOfMonth = DateTime(now.year, now.month, 1);
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return SafeArea(
      child: Scaffold(
        key: const PageStorageKey('leaveSubScreen'),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showLeaveDialog(context),
          tooltip:
              context.tr(
                shared.LocaleKeys.addLeaveTooltip,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Add Leave',
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: shared.DatePicker(
                startOfMonth,
                daysCount: daysInMonth,
                initialSelectedDate: _selectedDateNotifier.value,
                selectionColor: Theme.of(context).colorScheme.primaryContainer,
                selectedTextColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
                deactivatedColor: Theme.of(context).colorScheme.outline,
                monthTextStyle: Theme.of(context).textTheme.labelSmall!
                    .copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                dayTextStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                dateTextStyle: Theme.of(context).textTheme.titleMedium!
                    .copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                onDateChange: (date) {
                  _selectedDateNotifier.value = date;
                },
              ),
            ),
            StaffSearchBar(
              controller: _searchController,
              hintTexts: [
                context.tr(
                      shared.LocaleKeys.searchLeavesByNameHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Search employees by name',
                context.tr(
                      shared.LocaleKeys.searchLeavesByTypeHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Search employees by position',
                context.tr(
                      shared.LocaleKeys.searchLeavesByStatusHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Search leave by reason',
              ],
              onChanged: (value) =>
                  _searchQueryNotifier.value = value.toLowerCase(),
            ),
            Expanded(
              child: BlocConsumer<LeaveBloc, LeaveState>(
                listener: (context, state) {
                  if (state is LeaveErrorState) {
                    StaffManagementActions.showErrorDialog(
                      context,
                      state.message,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is LeaveLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LeaveLoadedState) {
                    if (state.leaves.isEmpty) {
                      return const LeaveEmptyView();
                    }
                    return ValueListenableBuilder<DateTime>(
                      valueListenable: _selectedDateNotifier,
                      builder: (context, selectedDate, child) {
                        return ValueListenableBuilder<String>(
                          valueListenable: _searchQueryNotifier,
                          builder: (context, query, child) {
                            final filteredList = state.leaves.where((item) {
                              final startStr =
                                  item.startDateTime ?? item.startDate;
                              final endStr = item.endDateTime ?? item.endDate;
                              if (startStr != null && endStr != null) {
                                final start = DateTime.tryParse(startStr);
                                final end = DateTime.tryParse(endStr);
                                if (start != null && end != null) {
                                  final dateDay = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                  );
                                  final startDay = DateTime(
                                    start.year,
                                    start.month,
                                    start.day,
                                  );
                                  final endDay = DateTime(
                                    end.year,
                                    end.month,
                                    end.day,
                                  );
                                  final isActive =
                                      (dateDay.isAtSameMomentAs(startDay) ||
                                          dateDay.isAfter(startDay)) &&
                                      (dateDay.isAtSameMomentAs(endDay) ||
                                          dateDay.isBefore(endDay));
                                  if (!isActive) return false;
                                } else {
                                  return false;
                                }
                              } else {
                                return false;
                              }

                              final nameMatch =
                                  item.employeeName?.toLowerCase().contains(
                                    query,
                                  ) ??
                                  false;
                              final typeMatch =
                                  item.leaveType?.toLowerCase().contains(
                                    query,
                                  ) ??
                                  false;
                              final statusMatch =
                                  item.status?.toLowerCase().contains(query) ??
                                  false;
                              final reasonMatch =
                                  item.reason?.toLowerCase().contains(query) ??
                                  false;
                              return query.isEmpty ||
                                  nameMatch ||
                                  typeMatch ||
                                  statusMatch ||
                                  reasonMatch;
                            }).toList();

                            if (filteredList.isEmpty) {
                              return LeaveEmptyView(
                                message:
                                    context.tr(
                                      shared
                                          .LocaleKeys
                                          .noMatchingLeaveApplications,
                                      track: shared
                                          .TrackConstants
                                          .staffManagementPageTrack,
                                    ) ??
                                    'No Leave Applications',
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<LeaveBloc>().add(
                                  LoadLeavesEvent(),
                                );
                              },
                              child: SlidableAutoCloseBehavior(
                                child: ListView.builder(
                                  key: const PageStorageKey('leaveListView'),
                                  controller: _scrollController,
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredList[index];
                                    return LeaveCard(
                                      leave: item,
                                      onEdit: () => _showLeaveDialog(
                                        context,
                                        leave: item,
                                      ),
                                      onDelete: () {
                                        if (item.id != null) {
                                          _confirmDelete(context, item.id!);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return Center(
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.noLeaveApplications,
                            track:
                                shared.TrackConstants.staffManagementPageTrack,
                          ) ??
                          'No Leave Applications',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
