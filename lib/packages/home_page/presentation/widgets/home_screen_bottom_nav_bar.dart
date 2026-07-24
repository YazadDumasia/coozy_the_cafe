import 'package:flutter/material.dart';

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
        BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Waiter'),
        BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Kitchen'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ],
    );
  }
}
