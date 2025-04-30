import 'package:flutter/cupertino.dart';

import 'dashboard.dart';
import 'schedule.dart';
import 'reports.dart';
import 'billing.dart';
import 'profile.dart';

final List<String> tabTitles = [
  'Dashboard',
  'Schedule',
  'Reports',
  'Billing',
  'Profile',
];

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.systemGrey,
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.2,
          ),
        ),
        items: [
          _buildTabBarItem(CupertinoIcons.home, CupertinoIcons.home, tabTitles[0]),
          _buildTabBarItem(CupertinoIcons.calendar, CupertinoIcons.calendar, tabTitles[1]),
          _buildTabBarItem(CupertinoIcons.chart_bar, CupertinoIcons.chart_bar, tabTitles[2]),
          _buildTabBarItem(CupertinoIcons.creditcard, CupertinoIcons.creditcard_fill, tabTitles[3]),
          _buildTabBarItem(CupertinoIcons.person, CupertinoIcons.person_fill, tabTitles[4]),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (context) {
            return _buildTabContent(index);
          },
        );
      },
    );
  }

  BottomNavigationBarItem _buildTabBarItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: CupertinoColors.inactiveGray, size: 20),
      activeIcon: Icon(activeIcon, color: CupertinoColors.activeBlue, size: 20),
      label: label,
    );
  }

  Widget _buildTabContent(int index) {
    final pages = [
      const DashboardPage(),
      const SchedulePage(),
      const ReportsPage(),
      const BillingPage(),
      const ProfilePage(),
    ];

    return pages[index];
  }
}


