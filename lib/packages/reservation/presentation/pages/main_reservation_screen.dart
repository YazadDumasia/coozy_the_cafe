import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../bloc/current_reservation_cubit.dart';
import '../bloc/upcoming_reservation_bloc.dart';
import '../bloc/reservation_action_cubit.dart';
import '../../domain/entities/reservation_entity.dart';
import '../widgets/reservation_card.dart';
import '../widgets/reservation_filter_bottom_sheet.dart';
import 'main_reservation_screen_actions.dart';

class MainReservationScreen extends StatefulWidget {
  const MainReservationScreen({super.key});

  @override
  State<MainReservationScreen> createState() => _MainReservationScreenState();
}

class _MainReservationScreenState extends State<MainReservationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _upcomingScrollController = ScrollController();
  final ValueNotifier<bool> _isSearchingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<ReservationFilterCriteria> _filterCriteriaNotifier =
      ValueNotifier<ReservationFilterCriteria>(
        const ReservationFilterCriteria(),
      );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _upcomingScrollController.addListener(
      () => MainReservationScreenActions.onScroll(
        context,
        _upcomingScrollController,
      ),
    );

    context.read<CurrentReservationCubit>().fetchCurrentReservations();
    context.read<UpcomingReservationBloc>().add(
      const FetchUpcomingReservations(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _upcomingScrollController.dispose();
    _isSearchingNotifier.dispose();
    _filterCriteriaNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = shared.TrackConstants.reservationPageTrack;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight + kTextTabBarHeight,
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isSearchingNotifier,
          builder: (context, isSearching, _) {
            return AppBar(
              title: isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            context.tr(
                              shared.LocaleKeys.searchReservationHint,
                              track: track,
                            ) ??
                            'Search by name or phone...',
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      onChanged: (query) =>
                          MainReservationScreenActions.onSearchChanged(
                            context,
                            query,
                          ),
                    )
                  : Text(
                      context.tr(
                            shared.LocaleKeys.reservationAppBarTitle,
                            track: track,
                          ) ??
                          'Reservations',
                    ),
              actions: [
                ValueListenableBuilder<ReservationFilterCriteria>(
                  valueListenable: _filterCriteriaNotifier,
                  builder: (context, criteria, _) {
                    return IconButton(
                      icon: Icon(
                        criteria.isActive
                            ? Icons.filter_alt_rounded
                            : Icons.filter_alt_outlined,
                        color: criteria.isActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      tooltip: 'Filter Reservations',
                      onPressed: () {
                        MainReservationScreenActions.showFilterBottomSheet(
                          context: context,
                          initialCriteria: criteria,
                          onApply: (newCriteria) {
                            _filterCriteriaNotifier.value = newCriteria;
                          },
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    final next = !_isSearchingNotifier.value;
                    _isSearchingNotifier.value = next;
                    if (!next) {
                      _searchController.clear();
                      MainReservationScreenActions.onSearchChanged(context, '');
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip:
                      context.tr(
                        shared.LocaleKeys.addReservationTooltip,
                        track: track,
                      ) ??
                      'Add Reservation',
                  onPressed: () =>
                      MainReservationScreenActions.openAddScreen(context),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: ValueListenableBuilder<ReservationFilterCriteria>(
                      valueListenable: _filterCriteriaNotifier,
                      builder: (context, criteria, _) {
                        return BlocBuilder<
                          CurrentReservationCubit,
                          CurrentReservationState
                        >(
                          builder: (context, state) {
                            final count = state is CurrentReservationLoaded
                                ? _filterReservationsSync(
                                    state.reservations,
                                    criteria,
                                  ).length
                                : 0;
                            final label =
                                context.tr(
                                  shared.LocaleKeys.currentTab,
                                  track: track,
                                ) ??
                                'Current';
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(label),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Tab(
                    child: ValueListenableBuilder<ReservationFilterCriteria>(
                      valueListenable: _filterCriteriaNotifier,
                      builder: (context, criteria, _) {
                        return BlocBuilder<
                          UpcomingReservationBloc,
                          UpcomingReservationState
                        >(
                          builder: (context, state) {
                            final count = state is UpcomingReservationLoaded
                                ? (criteria.isActive
                                      ? _filterReservationsSync(
                                          state.reservations,
                                          criteria,
                                        ).length
                                      : state.totalCount)
                                : 0;
                            final label =
                                context.tr(
                                  shared.LocaleKeys.upcomingTab,
                                  track: track,
                                ) ??
                                'Upcoming';
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(label),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: ValueListenableBuilder<ReservationFilterCriteria>(
        valueListenable: _filterCriteriaNotifier,
        builder: (context, criteria, _) {
          return Column(
            children: [
              if (criteria.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getFilterSummary(criteria),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _filterCriteriaNotifier.value =
                              const ReservationFilterCriteria();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child:
                    BlocListener<
                      ReservationActionCubit,
                      ReservationActionState
                    >(
                      listener: (context, state) {
                        if (state is ReservationActionError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCurrentTab(track, criteria),
                          _buildUpcomingTab(track, criteria),
                        ],
                      ),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getFilterSummary(ReservationFilterCriteria c) {
    final parts = <String>[];
    if (c.status != null) {
      final statusNames = [
        'Pending',
        'Confirmed',
        'Seated',
        'Completed',
        'Cancelled',
        'No-Show',
      ];
      if (c.status! >= 0 && c.status! < statusNames.length) {
        parts.add('Status: ${statusNames[c.status!]}');
      }
    }
    if (c.minGuests != null) {
      parts.add('Guests: ${c.minGuests}+');
    }
    if (c.dateFilter != 'all') {
      if (c.dateFilter == 'today') parts.add('Date: Today');
      if (c.dateFilter == 'tomorrow') parts.add('Date: Tomorrow');
      if (c.dateFilter == 'this_week') parts.add('Date: Next 7 Days');
    }
    return parts.join(' • ');
  }

  List<ReservationEntity> _filterReservationsSync(
    List<ReservationEntity> list,
    ReservationFilterCriteria criteria,
  ) {
    return _executeReservationFilterIsolate(
      ReservationFilterPayload(list, criteria),
    );
  }

  Future<List<ReservationEntity>> _filterReservationsAsync(
    List<ReservationEntity> list,
    ReservationFilterCriteria criteria,
  ) async {
    if (!criteria.isActive) return list;
    return await compute(
      _executeReservationFilterIsolate,
      ReservationFilterPayload(list, criteria),
    );
  }

  Widget _buildCurrentTab(String track, ReservationFilterCriteria criteria) {
    return BlocBuilder<CurrentReservationCubit, CurrentReservationState>(
      builder: (context, state) {
        if (state is CurrentReservationLoading) {
          return const shared.LoadingPage();
        }
        if (state is CurrentReservationError) {
          return shared.ErrorPage(
            onPressedRetryButton: () {
              MainReservationScreenActions.refreshAll(context);
            },
          );
        }
        if (state is CurrentReservationLoaded) {
          return FutureBuilder<List<ReservationEntity>>(
            future: _filterReservationsAsync(state.reservations, criteria),
            builder: (context, snapshot) {
              final filteredList =
                  snapshot.data ??
                  _filterReservationsSync(state.reservations, criteria);

              if (filteredList.isEmpty) {
                return Center(
                  child: Text(
                    criteria.isActive
                        ? 'No current reservations match the active filters.'
                        : (context.tr(
                                shared.LocaleKeys.noCurrentReservations,
                                track: track,
                              ) ??
                              'No current reservations found.'),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    MainReservationScreenActions.refreshAll(context),
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return ReservationCard(
                      reservation: item,
                      onTap: () =>
                          MainReservationScreenActions.onTapReservation(
                            context,
                            item,
                          ),
                      onEdit: () =>
                          MainReservationScreenActions.onEditReservation(
                            context,
                            item,
                          ),
                      onDelete: () =>
                          MainReservationScreenActions.onDeleteCurrentReservation(
                            context,
                            item,
                          ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUpcomingTab(String track, ReservationFilterCriteria criteria) {
    return BlocBuilder<UpcomingReservationBloc, UpcomingReservationState>(
      builder: (context, state) {
        if (state is UpcomingReservationLoading) {
          return const shared.LoadingPage();
        }
        if (state is UpcomingReservationError) {
          return shared.ErrorPage(
            onPressedRetryButton: () {
              MainReservationScreenActions.refreshAll(context);
            },
          );
        }
        if (state is UpcomingReservationLoaded) {
          return FutureBuilder<List<ReservationEntity>>(
            future: _filterReservationsAsync(state.reservations, criteria),
            builder: (context, snapshot) {
              final filteredList =
                  snapshot.data ??
                  _filterReservationsSync(state.reservations, criteria);

              if (filteredList.isEmpty) {
                return Center(
                  child: Text(
                    criteria.isActive
                        ? 'No upcoming reservations match the active filters.'
                        : (context.tr(
                                shared.LocaleKeys.noUpcomingReservations,
                                track: track,
                              ) ??
                              'No upcoming reservations found.'),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    MainReservationScreenActions.refreshAll(context),
                child: ListView.builder(
                  controller: _upcomingScrollController,
                  itemCount: state.hasReachedMax || criteria.isActive
                      ? filteredList.length
                      : filteredList.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= filteredList.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = filteredList[index];
                    return ReservationCard(
                      reservation: item,
                      onTap: () =>
                          MainReservationScreenActions.onTapReservation(
                            context,
                            item,
                          ),
                      onEdit: () =>
                          MainReservationScreenActions.onEditReservation(
                            context,
                            item,
                          ),
                      onDelete: () =>
                          MainReservationScreenActions.onDeleteUpcomingReservation(
                            context,
                            item,
                          ),
                    );
                  },
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class ReservationFilterPayload {
  final List<ReservationEntity> reservations;
  final ReservationFilterCriteria criteria;

  const ReservationFilterPayload(this.reservations, this.criteria);
}

List<ReservationEntity> _executeReservationFilterIsolate(
  ReservationFilterPayload payload,
) {
  final criteria = payload.criteria;
  final list = payload.reservations;
  if (!criteria.isActive) return list;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final endOfWeek = today.add(const Duration(days: 7));

  return list.where((item) {
    if (criteria.status != null && item.status != criteria.status) {
      return false;
    }
    if (criteria.minGuests != null &&
        (item.numberOfPeople ?? 0) < criteria.minGuests!) {
      return false;
    }
    final dateStr = item.reservationDateTime;
    if (criteria.dateFilter != 'all' && dateStr != null) {
      final itemDate = DateTime.tryParse(dateStr);
      if (itemDate != null) {
        final itemDay = DateTime(itemDate.year, itemDate.month, itemDate.day);
        if (criteria.dateFilter == 'today' && itemDay != today) {
          return false;
        }
        if (criteria.dateFilter == 'tomorrow' && itemDay != tomorrow) {
          return false;
        }
        if (criteria.dateFilter == 'this_week' &&
            (itemDay.isBefore(today) || itemDay.isAfter(endOfWeek))) {
          return false;
        }
      }
    }
    return true;
  }).toList();
}
