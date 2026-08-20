import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'home_screen_popup_menu.dart';
import 'home_screen_tab_bar_view.dart';

class HomeScreenMobileBody extends StatelessWidget {
  final ScrollController? scrollController;
  final TabController tabController;

  const HomeScreenMobileBody({
    super.key,
    this.scrollController,
    required this.tabController,
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
          actions: const <Widget>[HomeScreenPopupMenu()],
        ),
        SliverFillRemaining(
          child: HomeScreenTabBarView(tabController: tabController),
        ),
      ],
    );
  }
}
