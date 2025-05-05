// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/main.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';

import 'message.dart';
import 'schedule.dart';
import 'reports.dart';
import 'careai.dart';
import 'profile.dart';

final List<String> tabTitles = [
  'Schedule',
  'Reports',
  'Messages',
  'Care AI',
  'Profile',
];

class HomePage extends ConsumerStatefulWidget {
  static const String routeName = '/home';
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Cache the pages to maintain their state
  late final List<Widget> _pages;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
   
    _pages = [
  
      const ProviderScope(child: SchedulePage()),
      const ProviderScope(child: ReportsPage()),
      const ProviderScope(child: MessagePage()),
      const ProviderScope(child: CareAiPage(id: 'ibbi', email: 'ibbi@gmail.com')),
      const ProviderScope(child: ProfilePage()),
    ];
  }

  @override
  Widget build(BuildContext context) {

    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    
    // Watch auth state
    ref.watch(authProvider);
    
    
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.systemGrey,
        backgroundColor: isDark ? CupertinoColors.darkBackgroundGray : CupertinoColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? CupertinoColors.systemGrey.darkColor : CupertinoColors.systemGrey4,
            width: 0.2,
          ),
        ),
        items: [
          _buildTabBarItem(CupertinoIcons.calendar, CupertinoIcons.calendar, tabTitles[0], isDark),
          _buildTabBarItem(CupertinoIcons.chart_bar, CupertinoIcons.chart_bar, tabTitles[1], isDark),
          _buildTabBarItem(CupertinoIcons.chat_bubble_text, CupertinoIcons.chat_bubble_text, tabTitles[2], isDark),
          _buildTabBarItem(CupertinoIcons.circle_grid_3x3, CupertinoIcons.circle_grid_3x3, tabTitles[3], isDark),
          _buildTabBarItem(CupertinoIcons.person, CupertinoIcons.person, tabTitles[4], isDark),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (context) {
            return _pages[index];
          },
        );
      },
    );
  }

  BottomNavigationBarItem _buildTabBarItem(IconData icon, IconData activeIcon, String label, bool isDark) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: isDark ? CupertinoColors.systemGrey : CupertinoColors.inactiveGray, size: 20),
      activeIcon: Icon(activeIcon, color: CupertinoColors.activeBlue, size: 20),
      label: label,
    );
  }
}


