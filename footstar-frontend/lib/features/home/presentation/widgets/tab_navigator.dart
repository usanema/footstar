import 'package:flutter/material.dart';
import '../dashboard_screen.dart';
import '../../../explore/presentation/explore_screen.dart';

enum TabItem { home, explore, profile }

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    super.key,
    required this.navigatorKey,
    required this.tabItem,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => _getRootScreen());
      },
    );
  }

  Widget _getRootScreen() {
    switch (tabItem) {
      case TabItem.home:
        return const DashboardScreen();
      case TabItem.explore:
        return const ExploreScreen();
      case TabItem.profile:
        return const Center(
          child: Text(
            'Profile & Stats',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
    }
  }
}
