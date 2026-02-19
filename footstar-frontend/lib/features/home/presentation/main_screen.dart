import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import 'widgets/tab_navigator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    'home': GlobalKey<NavigatorState>(),
    'explore': GlobalKey<NavigatorState>(),
    'profile': GlobalKey<NavigatorState>(),
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final currentNavigatorKey = _getCurrentNavigatorKey();
        if (currentNavigatorKey.currentState?.canPop() ?? false) {
          currentNavigatorKey.currentState?.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            TabNavigator(
              navigatorKey: _navigatorKeys['home']!,
              tabItem: TabItem.home,
            ),
            TabNavigator(
              navigatorKey: _navigatorKeys['explore']!,
              tabItem: TabItem.explore,
            ),
            TabNavigator(
              navigatorKey: _navigatorKeys['profile']!,
              tabItem: TabItem.profile,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) {
              // Pop to first route if tapping the same tab
              _navigatorKeys.values
                  .elementAt(index)
                  .currentState
                  ?.popUntil((route) => route.isFirst);
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  GlobalKey<NavigatorState> _getCurrentNavigatorKey() {
    switch (_currentIndex) {
      case 0:
        return _navigatorKeys['home']!;
      case 1:
        return _navigatorKeys['explore']!;
      case 2:
        return _navigatorKeys['profile']!;
      default:
        return _navigatorKeys['home']!;
    }
  }
}
