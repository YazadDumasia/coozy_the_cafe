import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../../shared/coozy_shared.dart' as shared;
import 'home_screen_drawer.dart';
import '../widgets/home_screen_bottom_nav_bar.dart';
import '../widgets/home_screen_mobile_body.dart';
import 'home_screen_actions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  ScrollController? _scrollController;
  bool _isAppBarVisible = true;
  late TabController _tabController;
  final ValueNotifier<int> currentTabIndex = ValueNotifier<int>(0);

  DateTime? currentBackPressTime;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      currentTabIndex.value = _tabController.index;
    });
    _scrollController!.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController!.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isAppBarVisible) {
        _isAppBarVisible = false;
      }
    } else if (_scrollController!.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isAppBarVisible) {
        _isAppBarVisible = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;
          final bool shouldPop = await HomeScreenActions.handleBackPress(
            context,
            _scaffoldKey,
            _tabController,
            currentBackPressTime,
            (time) => currentBackPressTime = time,
          );
          if (shouldPop) {
            if (context.mounted) {
              if (kIsWeb) {
                // Exit app might not make sense in a browser, but handling gracefully
              } else {
                SystemNavigator.pop();
              }
            }
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          drawer: const HomeScreenDrawer(),
          bottomNavigationBar: !shared.ResponsiveLayout.isDesktop(context)
              ? ValueListenableBuilder<int>(
                  valueListenable: currentTabIndex,
                  builder: (context, tabIndex, child) {
                    return HomeScreenBottomNavBar(
                      tabController: _tabController,
                      currentTabIndex: tabIndex,
                    );
                  },
                )
              : null,
          body: shared.ResponsiveLayout(
            mobile: HomeScreenMobileBody(
              scrollController: _scrollController,
              tabController: _tabController,
            ),
            tablet: HomeScreenMobileBody(
              scrollController: _scrollController,
              tabController: _tabController,
            ),
            desktop: HomeScreenMobileBody(
              scrollController: _scrollController,
              tabController: _tabController,
            ),
            // desktop: HomeScreenWebBody(
            //   tabController: _tabController,
            //   scrollController: _scrollController,
            // ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    _tabController.dispose();
    currentTabIndex.dispose();
    super.dispose();
  }
}
