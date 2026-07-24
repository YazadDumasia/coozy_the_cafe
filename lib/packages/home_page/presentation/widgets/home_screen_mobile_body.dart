import 'package:flutter/material.dart';
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
          shape: RoundedRectangleBorder(),
          floating: true,
          pinned: true,
          title: Text('Coozy the Cafe'),
          actions: <Widget>[HomeScreenPopupMenu()],
        ),
        SliverFillRemaining(
          child: HomeScreenTabBarView(tabController: tabController),
        ),
      ],
    );
  }
}
