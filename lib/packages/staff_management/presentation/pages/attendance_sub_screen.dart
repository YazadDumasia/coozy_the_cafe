import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event_state.dart';
import '../../domain/entities/staff_entities.dart';
import '../widgets/attendance_card.dart';
import '../widgets/attendance_form_dialog.dart';
import '../widgets/staff_search_bar.dart';
import 'staff_management_screen_actions.dart';

class AttendanceSubScreen extends StatefulWidget {
  const AttendanceSubScreen({super.key});

  @override
  State<AttendanceSubScreen> createState() => _AttendanceSubScreenState();
}

class _AttendanceSubScreenState extends State<AttendanceSubScreen>
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
    context.read<AttendanceBloc>().add(LoadAttendanceEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    _scrollController.dispose();
    _selectedDateNotifier.dispose();
    super.dispose();
  }

  void _showAttendanceDialog(
    BuildContext context, {
    AttendanceEntity? attendance,
  }) {
    AttendanceFormDialog.show(
      context,
      attendance: attendance,
      onSubmit: (entity) {
        if (attendance == null) {
          context.read<AttendanceBloc>().add(
            AddAttendanceEvent(
              entity,
              onSuccess: () => StaffManagementActions.showSuccessDialog(
                context,
                context.tr(
                      shared.LocaleKeys.attendanceRecordedSuccess,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Attendance recorded successfully.',
              ),
              onError: (err) =>
                  StaffManagementActions.showErrorDialog(context, err),
            ),
          );
        } else {
          context.read<AttendanceBloc>().add(
            UpdateAttendanceEvent(
              entity,
              onSuccess: () => StaffManagementActions.showSuccessDialog(
                context,
                context.tr(
                      shared.LocaleKeys.attendanceUpdatedSuccess,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Attendance updated successfully.',
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
                  shared.LocaleKeys.deleteAttendanceConfirmMsg,
                  track: shared.TrackConstants.staffManagementPageTrack,
                ) ??
                'Do you really want to delete this attendance information? You will not be able to undo this action.',
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
    context.read<AttendanceBloc>().add(
      DeleteAttendanceEvent(
        id,
        onSuccess: () => StaffManagementActions.showSuccessDialog(
          context,
          context.tr(
                shared.LocaleKeys.attendanceDeletedSuccess,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Attendance deleted successfully.',
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
        key: const PageStorageKey('attendanceSubScreen'),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAttendanceDialog(context),
          tooltip:
              context.tr(
                shared.LocaleKeys.addAttendanceTooltip,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Add Employee Attendance',
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
                monthTextStyle: Theme.of(context).textTheme.labelMedium!
                    .copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                dayTextStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                dateTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
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
                      shared.LocaleKeys.searchAttendanceByNameHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Search employees by name',
                context.tr(
                      shared.LocaleKeys.searchAttendanceByStatusHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Search employees by mobile number',
                context.tr(
                      shared.LocaleKeys.searchAttendanceByDateHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Search employees by position',
              ],
              onChanged: (value) =>
                  _searchQueryNotifier.value = value.toLowerCase(),
            ),
            Expanded(
              child: BlocConsumer<AttendanceBloc, AttendanceState>(
                listener: (context, state) {
                  if (state is AttendanceErrorState) {
                    StaffManagementActions.showErrorDialog(
                      context,
                      state.message,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AttendanceLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AttendanceLoadedState) {
                    if (state.attendanceList.isEmpty) {
                      return Center(
                        child: Text(
                          context.tr(
                                shared.LocaleKeys.noAttendanceRecords,
                                track: shared
                                    .TrackConstants
                                    .staffManagementPageTrack,
                              ) ??
                              'No Attendance Records',
                        ),
                      );
                    }
                    return ValueListenableBuilder<DateTime>(
                      valueListenable: _selectedDateNotifier,
                      builder: (context, selectedDate, child) {
                        return ValueListenableBuilder<String>(
                          valueListenable: _searchQueryNotifier,
                          builder: (context, query, child) {
                            final filteredList = state.attendanceList.where((
                              item,
                            ) {
                              if (item.date != null) {
                                final parsed = DateTime.tryParse(item.date!);
                                if (parsed != null) {
                                  final isSameDay =
                                      parsed.year == selectedDate.year &&
                                      parsed.month == selectedDate.month &&
                                      parsed.day == selectedDate.day;
                                  if (!isSameDay) return false;
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
                              final statusMatch =
                                  item.status?.toLowerCase().contains(query) ??
                                  false;
                              final dateMatch =
                                  item.date?.toLowerCase().contains(query) ??
                                  false;
                              return query.isEmpty ||
                                  nameMatch ||
                                  statusMatch ||
                                  dateMatch;
                            }).toList();

                            if (filteredList.isEmpty) {
                              return Center(
                                child: Text(
                                  context.tr(
                                        shared
                                            .LocaleKeys
                                            .noMatchingAttendanceRecords,
                                        track: shared
                                            .TrackConstants
                                            .staffManagementPageTrack,
                                      ) ??
                                      'No Attendance Records',
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<AttendanceBloc>().add(
                                  LoadAttendanceEvent(),
                                );
                              },
                              child: SlidableAutoCloseBehavior(
                                child: ListView.builder(
                                  key: const PageStorageKey(
                                    'attendanceListView',
                                  ),
                                  controller: _scrollController,
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredList[index];
                                    return AttendanceCard(
                                      attendance: item,
                                      onEdit: () => _showAttendanceDialog(
                                        context,
                                        attendance: item,
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
                            shared.LocaleKeys.noAttendanceRecords,
                            track:
                                shared.TrackConstants.staffManagementPageTrack,
                          ) ??
                          'No Attendance Records',
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
