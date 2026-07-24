import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class HomeScreenTabBarView extends StatelessWidget {
  final TabController tabController;

  const HomeScreenTabBarView({super.key, required this.tabController});

  Widget buildPageTransitionSwitcher({Widget? screen, int? currentIndex}) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
          FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
      child: screen ?? Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: <Widget>[
        buildPageTransitionSwitcher(
          screen: Center(child: Text('Today')),
          currentIndex: 0,
        ),
        buildPageTransitionSwitcher(
          screen: Center(child: Text('Waiter')),
          currentIndex: 1,
        ),
        buildPageTransitionSwitcher(
          screen: Center(child: Text('Kitchen')),
          currentIndex: 2,
        ),
        buildPageTransitionSwitcher(
          screen: Center(child: Text('More')),
          currentIndex: 3,
        ),
      ],
    );
  }
}
