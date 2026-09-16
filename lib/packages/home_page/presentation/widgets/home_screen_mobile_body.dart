import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/kitchen_management/kitchen_management.dart';
import 'home_screen_popup_menu.dart';
import 'home_screen_tab_bar_view.dart';

class HomeScreenMobileBody extends StatelessWidget {
  final ScrollController? scrollController;
  final TabController tabController;
  final ValueNotifier<int>? currentTabIndex;

  const HomeScreenMobileBody({
    super.key,
    this.scrollController,
    required this.tabController,
    this.currentTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: <Widget>[
        SliverAppBar(
          shape: const RoundedRectangleBorder(),
          floating: true,
          pinned: true,
          title: Text(
            context.tr(
                  shared.LocaleKeys.homePageCoozyTheCafe,
                  track: shared.TrackConstants.homePageTrack,
                ) ??
                'Coozy the Cafe',
          ),
          actions: <Widget>[
            if (currentTabIndex != null)
              ValueListenableBuilder<int>(
                valueListenable: currentTabIndex!,
                builder: (context, activeIndex, _) {
                  if (activeIndex == 2) {
                    return IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip:
                          context.tr(
                            shared.LocaleKeys.kitchenRefreshOrders,
                            track: shared.TrackConstants.orderPageTrack,
                          ) ??
                          'Refresh Orders',
                      onPressed: () =>
                          KitchenPageActions.refreshOrders(context),
                    );
                  }
                  return const HomeScreenPopupMenu();
                },
              )
            else
              const HomeScreenPopupMenu(),
          ],
        ),
        SliverFillRemaining(
          child: HomeScreenTabBarView(tabController: tabController),
        ),
      ],
    );
  }
}
