import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class HomeScreenBottomNavBar extends StatelessWidget {
  final TabController tabController;
  final int currentTabIndex;

  const HomeScreenBottomNavBar({
    super.key,
    required this.tabController,
    required this.currentTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentTabIndex,
      onTap: (index) {
        tabController.animateTo(index);
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.today),
          label:
              context.tr(
                shared.LocaleKeys.homeTabToday,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Today',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label:
              context.tr(
                shared.LocaleKeys.homeTabWaiter,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Waiter',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.kitchen),
          label:
              context.tr(
                shared.LocaleKeys.homeTabKitchen,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Kitchen',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.more_horiz),
          label:
              context.tr(
                shared.LocaleKeys.homeTabMore,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'More',
        ),
      ],
    );
  }
}
