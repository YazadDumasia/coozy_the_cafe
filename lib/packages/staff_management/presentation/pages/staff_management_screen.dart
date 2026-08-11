import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/shared/config/app_extensions.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../home_page/presentation/pages/home_screen_drawer.dart';

class StaffManagementScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const StaffManagementScreen({super.key, required this.navigationShell});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(StaffManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != _tabController.index) {
      _tabController.animateTo(widget.navigationShell.currentIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const HomeScreenDrawer(),
        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.staffManagement,
                  track: shared.TrackConstants.staffManagementPageTrack,
                ) ??
                'Staff Management',
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            onTap: _onTabTapped,
            tabs: [
              Tab(
                text:
                    context.tr(
                      shared.LocaleKeys.staffEmployeesTab,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Employees',
              ),
              Tab(
                text:
                    context.tr(
                      shared.LocaleKeys.staffAttendanceTab,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Attendance',
              ),
              Tab(
                text:
                    context.tr(
                      shared.LocaleKeys.staffLeavesTab,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Leaves',
              ),
              Tab(
                text:
                    context.tr(
                      shared.LocaleKeys.staffReportsTab,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Reports',
              ),
            ],
          ),
        ),
        body: widget.navigationShell,
      ),
    );
  }
}
