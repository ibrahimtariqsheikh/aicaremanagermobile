import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/main.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.gear),
          onPressed: () {
            // Settings action
          },
        ),
      ),
      child: SafeArea(
        child: _buildProfileContent(context, ref, themeMode),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    final authState = ref.watch(authProvider);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: Text('Welcome ${authState.user.fullName}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CupertinoListSection.insetGrouped(
            backgroundColor: CupertinoColors.systemGroupedBackground,
            children: [
              _buildActionItem('Edit Profile', CupertinoIcons.person_fill),
              _buildActionItem('Change Password', CupertinoIcons.lock_fill),
              _buildThemeSwitcher(context, ref, themeMode),
              _buildActionItem('Log Out', CupertinoIcons.power),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSwitcher(BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    return CupertinoListTile(
      leading: Icon(
        themeMode == ThemeMode.dark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
        color: CupertinoColors.activeBlue,
      ),
      title: Text(
        'Theme',
        style: const TextStyle(decoration: TextDecoration.none),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Text(
          themeMode == ThemeMode.dark ? 'Dark' : 'Light',
          style: TextStyle(
            color: CupertinoColors.activeBlue,
            decoration: TextDecoration.none,
          ),
        ),
        onPressed: () {
          ref.read(themeProvider.notifier).state = 
            themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        },
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon) {
    return CupertinoListTile(
      leading: Icon(
        icon,
        color: CupertinoColors.activeBlue,
      ),
      title: Text(
        title,
        style: const TextStyle(decoration: TextDecoration.none),
      ),
      trailing: const CupertinoListTileChevron(),
      onTap: () {},
    );
  }
}
