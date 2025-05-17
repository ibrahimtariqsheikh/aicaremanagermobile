// ignore_for_file: avoid_print

import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/main.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:aicaremanagermob/pages/oboarding/sign_in_page.dart';

import 'message.dart';
import 'schedule.dart';
import 'reports_page.dart';

import 'profile.dart';

final List<String> tabTitles = [
  'Schedule',
  'Reports',
  'Messages',
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

    final authState = ref.read(authProvider);

    _pages = [
      const ProviderScope(child: SchedulePage()),
      ProviderScope(child: ReportsPage(userId: authState.user.id)),
      ProviderScope(child: MessagesPage()),
      const ProviderScope(child: ProfilePage()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final authState = ref.watch(authProvider);

    // Check if user is authenticated
    if (authState.user.id == 'default') {
      // User is not authenticated, redirect to sign in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SignInPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          (route) => false,
        );
      });
      return const SizedBox.shrink(); // Return empty widget while redirecting
    }

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: AppColors.background,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.systemGrey,
        border: Border(
          top: BorderSide(
            color: isDark
                ? CupertinoColors.systemGrey.darkColor
                : CupertinoColors.systemGrey4,
            width: 0.2,
          ),
        ),
        items: [
          _buildTabBarItem(CupertinoIcons.calendar, CupertinoIcons.calendar,
              tabTitles[0], isDark),
          _buildTabBarItem(CupertinoIcons.chart_bar, CupertinoIcons.chart_bar,
              tabTitles[1], isDark),
          _buildTabBarItem(CupertinoIcons.chat_bubble_text,
              CupertinoIcons.chat_bubble_text, tabTitles[2], isDark),
          _buildTabBarItem(CupertinoIcons.person, CupertinoIcons.person,
              tabTitles[3], isDark),
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

  BottomNavigationBarItem _buildTabBarItem(
      IconData icon, IconData activeIcon, String label, bool isDark) {
    return BottomNavigationBarItem(
      icon: Icon(icon,
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.inactiveGray,
          size: 20),
      activeIcon: Icon(activeIcon, color: CupertinoColors.activeBlue, size: 20),
      label: label,
    );
  }
}
