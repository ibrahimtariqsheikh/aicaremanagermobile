import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/main.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
            decoration: TextDecoration.none,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.gear,
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
          ),
          onPressed: () {
            // Settings action
          },
        ),
        backgroundColor: isDark ? CupertinoColors.darkBackgroundGray : CupertinoColors.systemBackground,
        border: null,
      ),
      child: SafeArea(
        child: _buildDashboardContent(isDark),
      ),
    );
  }

  Widget _buildDashboardContent(bool isDark) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: CupertinoSearchTextField(),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildSection('Today\'s Summary', isDark),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildStatCard('Appointments', '8', CupertinoColors.activeBlue, isDark),
                _buildStatCard('Tasks', '3', CupertinoColors.systemOrange, isDark),
                _buildStatCard('Messages', '12', CupertinoColors.systemGreen, isDark),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildSection('Recent Activity', isDark),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            _buildListItem(
              'Meeting with John',
              'Today, 2:00 PM',
              CupertinoIcons.person_crop_circle_fill,
              CupertinoColors.activeBlue,
              isDark,
            ),
            _buildListItem(
              'Project Review',
              'Today, 4:30 PM',
              CupertinoIcons.doc_text_fill,
              CupertinoColors.systemIndigo,
              isDark,
            ),
            _buildListItem(
              'Client Call',
              'Tomorrow, 10:00 AM',
              CupertinoIcons.phone_fill,
              CupertinoColors.systemGreen,
              isDark,
            ),
            _buildListItem(
              'Team Discussion',
              'Tomorrow, 2:00 PM',
              CupertinoIcons.group_solid,
              CupertinoColors.systemTeal,
              isDark,
            ),
          ]),
        ),
        SliverToBoxAdapter(
          child: _buildSection('Quick Actions', isDark),
        ),
        SliverToBoxAdapter(
          child: CupertinoListSection.insetGrouped(
            backgroundColor: isDark ? CupertinoColors.darkBackgroundGray : CupertinoColors.systemGroupedBackground,
            children: [
              _buildActionItem('Add New Appointment', CupertinoIcons.calendar_badge_plus, isDark),
              _buildActionItem('Create Report', CupertinoIcons.chart_bar_fill, isDark),
              _buildActionItem('Send Invoice', CupertinoIcons.doc_text_fill, isDark),
            ],
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildSection(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? CupertinoColors.white : CupertinoColors.label,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: isDark ? CupertinoColors.darkBackgroundGray : CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? CupertinoColors.black.withOpacity(0.2) : CupertinoColors.systemGrey6,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.chart_bar_fill,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: color,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle, IconData icon, Color color, bool isDark) {
    return CupertinoListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
          decoration: TextDecoration.none,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel,
          decoration: TextDecoration.none,
        ),
      ),
      trailing: const CupertinoListTileChevron(),
      onTap: () {},
    );
  }

  Widget _buildActionItem(String title, IconData icon, bool isDark) {
    return CupertinoListTile(
      leading: Icon(
        icon,
        color: CupertinoColors.activeBlue,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
          decoration: TextDecoration.none,
        ),
      ),
      trailing: const CupertinoListTileChevron(),
      onTap: () {},
    );
  }
}
