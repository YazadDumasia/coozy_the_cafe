import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_info.dart';
import '../../domain/entities/reservation_entity.dart';
import '../bloc/reservation_action_cubit.dart';
import '../widgets/table_picker_view.dart';
import '../widgets/menu_item_picker_view.dart';
import 'add_edit_reservation_screen_actions.dart';

class AddEditReservationScreen extends StatefulWidget {
  final ReservationEntity? reservation;

  const AddEditReservationScreen({super.key, this.reservation});

  @override
  State<AddEditReservationScreen> createState() =>
      _AddEditReservationScreenState();
}

class _AddEditReservationScreenState extends State<AddEditReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _guestsController;
  late TextEditingController _notesController;
  final FocusNode _phoneFocusNode = FocusNode();

  final ValueNotifier<String> _isoCodeNotifier = ValueNotifier<String>('IN');
  final ValueNotifier<DateTime?> _dateTimeNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<List<TableInfo>> _selectedTablesNotifier =
      ValueNotifier<List<TableInfo>>([]);
  final ValueNotifier<List<PreOrderedMenuItemEntity>>
  _selectedMenuItemsNotifier = ValueNotifier<List<PreOrderedMenuItemEntity>>(
    [],
  );
  final ValueNotifier<int> _statusNotifier = ValueNotifier<int>(0);

  bool get _isEdit => widget.reservation != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reservation;
    _nameController = TextEditingController(text: r?.customerName ?? '');
    _phoneController = TextEditingController(text: r?.phoneNumber ?? '');
    _guestsController = TextEditingController(
      text: r?.numberOfPeople?.toString() ?? '2',
    );
    _notesController = TextEditingController(text: r?.notes ?? '');

    _statusNotifier.value = r?.status ?? 0;
    _isoCodeNotifier.value = r?.isoCode ?? 'IN';

    if (r?.reservationDateTime != null) {
      _dateTimeNotifier.value = DateTime.tryParse(r!.reservationDateTime!);
    } else {
      _dateTimeNotifier.value = DateTime.now().add(const Duration(hours: 1));
    }

    if (r?.tableReservedName != null && r!.tableReservedName!.isNotEmpty) {
      final names = r.tableReservedName!.split(', ');
      _selectedTablesNotifier.value = names
          .map((name) => TableInfo(id: r.tableId, tableLabel: name))
          .toList();
    } else if (r?.tableId != null) {
      _selectedTablesNotifier.value = [
        TableInfo(id: r!.tableId, tableLabel: r.tableReservedName),
      ];
    }

    if (r?.preOrderedItems != null) {
      _selectedMenuItemsNotifier.value = List.from(r!.preOrderedItems);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _guestsController.dispose();
    _notesController.dispose();
    _phoneFocusNode.dispose();

    _isoCodeNotifier.dispose();
    _dateTimeNotifier.dispose();
    _selectedTablesNotifier.dispose();
    _selectedMenuItemsNotifier.dispose();
    _statusNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTimeNotifier.value ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _dateTimeNotifier.value != null
          ? TimeOfDay.fromDateTime(_dateTimeNotifier.value!)
          : TimeOfDay.now(),
    );
    if (time == null) return;

    _dateTimeNotifier.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_dateTimeNotifier.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time.')),
      );
      return;
    }

    final selectedTables = _selectedTablesNotifier.value;
    final primaryTableId = selectedTables.isNotEmpty
        ? selectedTables.first.id
        : null;
    final combinedTableNames = selectedTables
        .map((t) => t.tableLabel ?? t.tableNo ?? 'Table')
        .join(', ');

    AddEditReservationScreenActions.submitForm(
      context: context,
      isEdit: _isEdit,
      id: widget.reservation?.id,
      hashId: widget.reservation?.hashId,
      customerName: _nameController.text,
      phone: _phoneController.text,
      isoCode: _isoCodeNotifier.value,
      guestsStr: _guestsController.text,
      dateTime: _dateTimeNotifier.value,
      primaryTableId: primaryTableId,
      combinedTableNames: combinedTableNames,
      selectedMenuItems: _selectedMenuItemsNotifier.value,
      notes: _notesController.text,
      status: _statusNotifier.value,
      creationDate: widget.reservation?.creationDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final track = shared.TrackConstants.reservationPageTrack;

    return BlocListener<ReservationActionCubit, ReservationActionState>(
      listener: (context, state) =>
          AddEditReservationScreenActions.onActionResult(
            context: context,
            state: state,
            isEdit: _isEdit,
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEdit
                ? (context.tr(
                        shared.LocaleKeys.editReservationTitle,
                        track: track,
                      ) ??
                      'Edit Reservation')
                : (context.tr(
                        shared.LocaleKeys.addReservationTitle,
                        track: track,
                      ) ??
                      'Create Reservation'),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [],
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),

                  body: shared.ResponsiveLayout(
                    mobile: _buildMobileLayout(track),
                    tablet: _buildTabletDesktopLayout(track, isDesktop: false),
                    desktop: _buildTabletDesktopLayout(track, isDesktop: true),
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(top: false, child: _buildSubmitButton(track)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTableChips() {
    return ValueListenableBuilder<List<TableInfo>>(
      valueListenable: _selectedTablesNotifier,
      builder: (context, selectedTables, _) {
        if (selectedTables.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: selectedTables.map((t) {
              return Chip(
                avatar: const Icon(Icons.table_restaurant, size: 16),
                label: Text(t.tableLabel ?? t.tableNo ?? 'Table'),
                visualDensity: VisualDensity.compact,
                onDeleted: () {
                  final updated = List<TableInfo>.from(selectedTables)
                    ..removeWhere((item) => item.id == t.id);
                  _selectedTablesNotifier.value = updated;
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSelectedMenuChips() {
    return ValueListenableBuilder<List<PreOrderedMenuItemEntity>>(
      valueListenable: _selectedMenuItemsNotifier,
      builder: (context, selectedMenuItems, _) {
        if (selectedMenuItems.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: selectedMenuItems.map((item) {
              return Chip(
                avatar: const Icon(Icons.fastfood, size: 16),
                label: Text('${item.itemName} x${item.quantity}'),
                visualDensity: VisualDensity.compact,
                onDeleted: () {
                  final updated = List<PreOrderedMenuItemEntity>.from(
                    selectedMenuItems,
                  )..removeWhere((i) => i.itemId == item.itemId);
                  _selectedMenuItemsNotifier.value = updated;
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(String track) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNameField(track),
        const SizedBox(height: 16),
        _buildPhoneField(track),
        const SizedBox(height: 16),
        _buildDateTimeField(track),
        const SizedBox(height: 16),
        _buildGuestsField(track),
        const SizedBox(height: 16),
        _buildNotesField(track),
        const SizedBox(height: 16),
        _buildStatusField(track),
        const SizedBox(height: 24),
        _buildTablePickerHeader(track),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<TableInfo>>(
          valueListenable: _selectedTablesNotifier,
          builder: (context, selectedTables, _) {
            return TablePickerView(
              selectedTables: selectedTables,
              onTablesChanged: (tables) =>
                  _selectedTablesNotifier.value = tables,
            );
          },
        ),
        _buildSelectedTableChips(),
        const SizedBox(height: 24),
        _buildMenuPickerHeader(track),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<PreOrderedMenuItemEntity>>(
          valueListenable: _selectedMenuItemsNotifier,
          builder: (context, selectedItems, _) {
            return MenuItemPickerView(
              selectedItems: selectedItems,
              onItemsChanged: (items) =>
                  _selectedMenuItemsNotifier.value = items,
            );
          },
        ),
        _buildSelectedMenuChips(),
      ],
    );
  }

  Widget _buildTabletDesktopLayout(String track, {required bool isDesktop}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildNameField(track)),
            const SizedBox(width: 16),
            Expanded(child: _buildPhoneField(track)),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDateTimeField(track)),
            const SizedBox(width: 16),
            Expanded(child: _buildGuestsField(track)),
          ],
        ),
        const SizedBox(height: 16),
        _buildNotesField(track).inExpandedRow(),
        const SizedBox(height: 16),
        _buildStatusField(track).inExpandedRow(),

        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTablePickerHeader(track),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<List<TableInfo>>(
                    valueListenable: _selectedTablesNotifier,
                    builder: (context, selectedTables, _) {
                      return TablePickerView(
                        selectedTables: selectedTables,
                        onTablesChanged: (tables) =>
                            _selectedTablesNotifier.value = tables,
                      );
                    },
                  ),
                  _buildSelectedTableChips(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuPickerHeader(track),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<List<PreOrderedMenuItemEntity>>(
                    valueListenable: _selectedMenuItemsNotifier,
                    builder: (context, selectedItems, _) {
                      return MenuItemPickerView(
                        selectedItems: selectedItems,
                        onItemsChanged: (items) =>
                            _selectedMenuItemsNotifier.value = items,
                      );
                    },
                  ),
                  _buildSelectedMenuChips(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTablePickerHeader(String track) {
    return ValueListenableBuilder<List<TableInfo>>(
      valueListenable: _selectedTablesNotifier,
      builder: (context, selectedTables, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.tr(shared.LocaleKeys.selectTableLabel, track: track) ??
                    'Select Table Arrangement(s)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selectedTables.isNotEmpty) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text('${selectedTables.length} selected'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMenuPickerHeader(String track) {
    return ValueListenableBuilder<List<PreOrderedMenuItemEntity>>(
      valueListenable: _selectedMenuItemsNotifier,
      builder: (context, selectedMenuItems, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.tr(
                      shared.LocaleKeys.selectMenuItemsLabel,
                      track: track,
                    ) ??
                    'Pre-order Menu Items',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selectedMenuItems.isNotEmpty) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Chip(
                  label: Text(
                    '${selectedMenuItems.fold(0, (sum, i) => sum + i.quantity)} items (\$${selectedMenuItems.fold(0.0, (sum, i) => sum + (i.price * i.quantity)).toStringAsFixed(2)})',
                    overflow: TextOverflow.ellipsis,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton(String track) {
    return BlocBuilder<ReservationActionCubit, ReservationActionState>(
      builder: (context, state) {
        final isLoading = state is ReservationActionLoading;
        return SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : _onSave,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator()
                : Text(
                    _isEdit
                        ? (context.tr(
                                shared.LocaleKeys.updateReservationBtn,
                                track: track,
                              ) ??
                              'Update Reservation')
                        : (context.tr(
                                shared.LocaleKeys.saveReservationBtn,
                                track: track,
                              ) ??
                              'Save Reservation'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildNameField(String track) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText:
            context.tr(shared.LocaleKeys.customerNameLabel, track: track) ??
            'Customer Name',
        hintText:
            context.tr(shared.LocaleKeys.customerNameHint, track: track) ??
            'Enter customer name',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.person),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return context.tr(
                shared.LocaleKeys.customerNameError,
                track: track,
              ) ??
              'Customer name is required';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(String track) {
    return ValueListenableBuilder<String>(
      valueListenable: _isoCodeNotifier,
      builder: (context, isoCode, _) {
        return shared.PhoneNumberTextFormField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          showDropdownIcon: true,
          showCountryFlag: true,
          initialCountryCode: isoCode,
          flagsButtonMargin: const EdgeInsets.all(10),
          isCountryButtonPersistent: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText:
                context.tr(shared.LocaleKeys.phoneNumberLabel, track: track) ??
                'Phone Number',
            hintText:
                context.tr(shared.LocaleKeys.phoneNumberHint, track: track) ??
                'Enter phone number',
            border: const OutlineInputBorder(),
          ),
          onCountryChanged: (shared.Country country) {
            _isoCodeNotifier.value = country.isoCode;
          },
        );
      },
    );
  }

  Widget _buildDateTimeField(String track) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: _dateTimeNotifier,
      builder: (context, selectedDateTime, _) {
        return InkWell(
          onTap: _pickDateTime,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText:
                  context.tr(shared.LocaleKeys.dateTimeLabel, track: track) ??
                  'Reservation Date & Time',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              selectedDateTime != null
                  ? selectedDateTime
                        .toIso8601String()
                        .substring(0, 16)
                        .replaceAll('T', ' ')
                  : (context.tr(shared.LocaleKeys.dateTimeHint, track: track) ??
                        'Select Date & Time'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestsField(String track) {
    return TextFormField(
      controller: _guestsController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText:
            context.tr(shared.LocaleKeys.numberOfPeopleLabel, track: track) ??
            'Number of Guests',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.group),
      ),
    );
  }

  Widget _buildNotesField(String track) {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(20),
        labelText:
            context.tr(shared.LocaleKeys.notesLabel, track: track) ??
            'Notes / Special Requests',
        hintText:
            context.tr(shared.LocaleKeys.notesHint, track: track) ??
            'Add notes...',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.note),
      ),
    );
  }

  Widget _buildStatusField(String track) {
    return ValueListenableBuilder<int>(
      valueListenable: _statusNotifier,
      builder: (context, status, _) {
        return DropdownButtonFormField<int>(
          initialValue: status,
          decoration: InputDecoration(
            labelText:
                context.tr(shared.LocaleKeys.statusLabel, track: track) ??
                'Status',
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(
                context.tr(shared.LocaleKeys.statusPending, track: track) ??
                    'Pending',
              ),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text(
                context.tr(shared.LocaleKeys.statusConfirmed, track: track) ??
                    'Confirmed',
              ),
            ),
            DropdownMenuItem(
              value: 2,
              child: Text(
                context.tr(shared.LocaleKeys.statusCompleted, track: track) ??
                    'Completed',
              ),
            ),
            DropdownMenuItem(
              value: 3,
              child: Text(
                context.tr(shared.LocaleKeys.statusCancelled, track: track) ??
                    'Cancelled',
              ),
            ),
          ],
          onChanged: (val) {
            if (val != null) _statusNotifier.value = val;
          },
        );
      },
    );
  }
}
