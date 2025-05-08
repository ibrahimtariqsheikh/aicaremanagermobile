import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aicaremanagermob/main.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return defaultTargetPlatform == TargetPlatform.iOS
        ? _buildIOSProfile(context, ref, themeMode, theme)
        : _buildAndroidProfile(context, ref, themeMode, theme);
  }

  Widget _buildIOSProfile(BuildContext context, WidgetRef ref,
      ThemeMode themeMode, ThemeData theme) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(LucideIcons.settings, color: theme.iconTheme.color),
          onPressed: () {
            // Settings action
          },
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildProfileHeader(ref, theme),
            _buildPersonalInfoSection(ref, theme),
            _buildSettingsSection(ref, themeMode, theme),
            _buildLogoutSection(ref, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidProfile(BuildContext context, WidgetRef ref,
      ThemeMode themeMode, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.settings, color: theme.iconTheme.color),
            onPressed: () {
              // Settings action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(ref, theme),
            _buildPersonalInfoSectionAndroid(ref, theme),
            _buildHealthInfoSectionAndroid(ref, theme),
            _buildSettingsSectionAndroid(ref, themeMode, theme),
            _buildLogoutSectionAndroid(ref, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(WidgetRef ref, ThemeData theme) {
    final user = ref.watch(authProvider).user;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                LucideIcons.user,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.inactiveGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(WidgetRef ref, ThemeData theme) {
    final user = ref.watch(authProvider).user;

    return SliverToBoxAdapter(
      child: CupertinoListSection.insetGrouped(
        header: const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        backgroundColor: theme.scaffoldBackgroundColor,
        children: [
          _buildInfoItem('Role', user.role.toString().split('.').last, theme),
          _buildInfoItem(
              'Sub Role', user.subRole?.toString().split('.').last, theme),
          _buildInfoItem('Phone', user.phoneNumber, theme),
          _buildInfoItem('Address',
              '${user.address}, ${user.city}, ${user.province}', theme),
          _buildInfoItem('Postal Code', user.postalCode, theme),
          _buildInfoItem(
              'Date of Birth', user.dateOfBirth?.toIso8601String(), theme),
          _buildInfoItem('Languages', user.languages, theme),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
      WidgetRef ref, ThemeMode themeMode, ThemeData theme) {
    return SliverToBoxAdapter(
      child: CupertinoListSection.insetGrouped(
        header: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        backgroundColor: theme.scaffoldBackgroundColor,
        children: [
          _buildActionItem('Edit Profile', LucideIcons.user, theme),
          _buildActionItem('Change Password', LucideIcons.lock, theme),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(WidgetRef ref, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: CupertinoColors.activeBlue,
          borderRadius: BorderRadius.circular(8),
          child: Text(
            'Log Out',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: CupertinoColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () {
            // Handle logout
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String? value, ThemeData theme) {
    return CupertinoListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.label,
        ),
      ),
      trailing: Text(
        value ?? 'Not specified',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.inactiveGray,
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, ThemeData theme) {
    return CupertinoListTile(
      leading: Icon(
        icon,
        size: 15,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.label,
        ),
      ),
      trailing: const CupertinoListTileChevron(),
      onTap: () {},
    );
  }

  Widget _buildPersonalInfoSectionAndroid(WidgetRef ref, ThemeData theme) {
    final user = ref.watch(authProvider).user;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildInfoItemAndroid(
              'Role', user.role.toString().split('.').last, theme),
          _buildInfoItemAndroid(
              'Sub Role', user.subRole?.toString().split('.').last, theme),
          _buildInfoItemAndroid('Phone', user.phoneNumber, theme),
          _buildInfoItemAndroid('Address',
              '${user.address}, ${user.city}, ${user.province}', theme),
          _buildInfoItemAndroid('Postal Code', user.postalCode, theme),
          _buildInfoItemAndroid(
              'Date of Birth', user.dateOfBirth?.toIso8601String(), theme),
          _buildInfoItemAndroid('Languages', user.languages, theme),
        ],
      ),
    );
  }

  Widget _buildHealthInfoSectionAndroid(WidgetRef ref, ThemeData theme) {
    final user = ref.watch(authProvider).user;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Health Information',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildInfoItemAndroid('NHS Number', user.nhsNumber, theme),
          _buildInfoItemAndroid('Mobility', user.mobility, theme),
          _buildInfoItemAndroid('Allergies', user.allergies, theme),
          _buildInfoItemAndroid('Likes/Dislikes', user.likesDislikes, theme),
          _buildInfoItemAndroid('Interests', user.interests, theme),
          _buildInfoItemAndroid('History', user.history, theme),
        ],
      ),
    );
  }

  Widget _buildSettingsSectionAndroid(
      WidgetRef ref, ThemeMode themeMode, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildActionItemAndroid('Edit Profile', LucideIcons.user, theme),
          _buildActionItemAndroid('Change Password', LucideIcons.lock, theme),
          _buildThemeSwitcherAndroid(ref, themeMode, theme),
        ],
      ),
    );
  }

  Widget _buildLogoutSectionAndroid(WidgetRef ref, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          // Handle logout
        },
        child: Text(
          'Log Out',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItemAndroid(String title, String? value, ThemeData theme) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: Text(
        value ?? 'Not specified',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildThemeSwitcherAndroid(
      WidgetRef ref, ThemeMode themeMode, ThemeData theme) {
    return ListTile(
      leading: Icon(
        themeMode == ThemeMode.dark ? LucideIcons.moon : LucideIcons.sun,
        color: theme.colorScheme.primary,
        size: 20,
      ),
      title: Text(
        'Theme',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: TextButton(
        onPressed: () {
          ref.read(themeProvider.notifier).state =
              themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        },
        child: Text(
          themeMode == ThemeMode.dark ? 'Dark' : 'Light',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionItemAndroid(String title, IconData icon, ThemeData theme) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
