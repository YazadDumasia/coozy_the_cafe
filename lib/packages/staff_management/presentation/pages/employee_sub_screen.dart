import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../bloc/employee/employee_bloc.dart';
import '../bloc/employee/employee_event_state.dart';
import '../../domain/entities/staff_entities.dart';
import '../widgets/employee_card.dart';
import '../widgets/employee_form_dialog.dart';
import '../widgets/staff_search_bar.dart';
import 'staff_management_screen_actions.dart';

class EmployeeSubScreen extends StatefulWidget {
  const EmployeeSubScreen({super.key});

  @override
  State<EmployeeSubScreen> createState() => _EmployeeSubScreenState();
}

class _EmployeeSubScreenState extends State<EmployeeSubScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(LoadEmployeesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showEmployeeFormDialog(
    BuildContext context, {
    EmployeeEntity? employee,
  }) {
    EmployeeFormDialog.show(
      context,
      employee: employee,
      onSubmit: (newEntity) {
        if (employee == null) {
          context.read<EmployeeBloc>().add(
            AddEmployeeEvent(
              newEntity,
              onSuccess: () => StaffManagementActions.showSuccessDialog(
                context,
                context.tr(
                      shared.LocaleKeys.employeeAddedSuccess,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Employee added successfully.',
              ),
              onError: (err) =>
                  StaffManagementActions.showErrorDialog(context, err),
            ),
          );
        } else {
          context.read<EmployeeBloc>().add(
            UpdateEmployeeEvent(
              newEntity,
              onSuccess: () => StaffManagementActions.showSuccessDialog(
                context,
                context.tr(
                      shared.LocaleKeys.employeeUpdatedSuccess,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Employee updated successfully.',
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
                  shared.LocaleKeys.deleteEmployeeConfirmMsg,
                  track: shared.TrackConstants.staffManagementPageTrack,
                ) ??
                'Do you really want to delete this employee information? You will not be able to undo this action.',
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
    context.read<EmployeeBloc>().add(
      DeleteEmployeeEvent(
        id,
        onSuccess: () => StaffManagementActions.showSuccessDialog(
          context,
          context.tr(
                shared.LocaleKeys.employeeDeletedSuccess,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Employee deleted successfully.',
        ),
        onError: (err) => StaffManagementActions.showErrorDialog(context, err),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        key: const PageStorageKey('employeeSubScreen'),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showEmployeeFormDialog(context),
          tooltip:
              context.tr(
                shared.LocaleKeys.addEmployeeTooltip,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Add Employee',
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            StaffSearchBar(
              controller: _searchController,
              hintTexts: [
                context.tr(
                      shared.LocaleKeys.searchEmployeeByNameHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Search employees by name',
                context.tr(
                      shared.LocaleKeys.searchEmployeeByPositionHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Search employees by position',
                context.tr(
                      shared.LocaleKeys.searchEmployeeByContactHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Search employees by mobile number',
              ],
              onChanged: (value) =>
                  context.read<EmployeeBloc>().add(SearchEmployeesEvent(value)),
            ),
            Expanded(
              child: BlocConsumer<EmployeeBloc, EmployeeState>(
                listener: (context, state) {
                  if (state is EmployeeErrorState) {
                    StaffManagementActions.showErrorDialog(
                      context,
                      state.message,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is EmployeeLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is EmployeeLoadedState) {
                    if (state.employees.isEmpty) {
                      return Center(
                        child: Text(
                          context.tr(
                                shared.LocaleKeys.noEmployeesFound,
                                track: shared
                                    .TrackConstants
                                    .staffManagementPageTrack,
                              ) ??
                              'No Employees Found',
                        ),
                      );
                    }

                    final isSearching = _searchController.text
                        .trim()
                        .isNotEmpty;

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<EmployeeBloc>().add(LoadEmployeesEvent());
                      },
                      child: SlidableAutoCloseBehavior(
                        child: shared.AzListView(
                          key: const PageStorageKey('employeeListView'),
                          data: state.employees,
                          itemCount: state.employees.length,
                          indexBarData: isSearching
                              ? const []
                              : shared.kIndexBarData
                                    .where(
                                      (tag) => state.employees.any(
                                        (e) => e.getSuspensionTag() == tag,
                                      ),
                                    )
                                    .toList(),
                          itemBuilder: (context, index) {
                            final item = state.employees[index];
                            return EmployeeCard(
                              employee: item,
                              onEdit: () => _showEmployeeFormDialog(
                                context,
                                employee: item,
                              ),
                              onDelete: () {
                                if (item.id != null) {
                                  _confirmDelete(context, item.id!);
                                }
                              },
                            );
                          },
                          susItemBuilder: isSearching
                              ? null
                              : (context, index) {
                                  final tag = state.employees[index]
                                      .getSuspensionTag();
                                  return Container(
                                    height: 36,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      tag,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                    ),
                                  );
                                },
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
