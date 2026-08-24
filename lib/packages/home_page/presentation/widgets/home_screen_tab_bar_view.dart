import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/waiter_order_placement.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/kitchen_management.dart';

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
          screen: Center(
            child: Text(
              context.tr(
                    shared.LocaleKeys.homeTabToday,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Today',
            ),
          ),
          currentIndex: 0,
        ),
        buildPageTransitionSwitcher(
          screen: const WaiterOrderPlacementScreen(),
          currentIndex: 1,
        ),
        buildPageTransitionSwitcher(
          screen: BlocProvider<KitchenBloc>(
            create: (_) =>
                sl<KitchenBloc>()..add(const LoadKitchenOrdersEvent()),
            child: const KitchenScreen(),
          ),
          currentIndex: 2,
        ),
        buildPageTransitionSwitcher(
          screen: Center(
            child: Text(
              context.tr(
                    shared.LocaleKeys.homeTabMore,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'More',
            ),
          ),
          currentIndex: 3,
        ),
      ],
    );
  }
}
