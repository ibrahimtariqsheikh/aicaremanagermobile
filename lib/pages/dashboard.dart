import 'package:flutter/cupertino.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Dashboard',
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
        child: _buildDashboardContent(),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: CupertinoSearchTextField(),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildSection('Today\'s Summary'),
        ),
      
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildStatCard('Appointments', '8', CupertinoColors.activeBlue),
                _buildStatCard('Tasks', '3', CupertinoColors.systemOrange),
                _buildStatCard('Messages', '12', CupertinoColors.systemGreen),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildSection('Recent Activity'),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            _buildListItem(
              'Meeting with John',
              'Today, 2:00 PM',
              CupertinoIcons.person_crop_circle_fill,
              CupertinoColors.activeBlue,
            ),
            _buildListItem(
              'Project Review',
              'Today, 4:30 PM',
              CupertinoIcons.doc_text_fill,
              CupertinoColors.systemIndigo,
            ),
            _buildListItem(
              'Client Call',
              'Tomorrow, 10:00 AM',
              CupertinoIcons.phone_fill,
              CupertinoColors.systemGreen,
            ),
            _buildListItem(
              'Team Discussion',
              'Tomorrow, 2:00 PM',
              CupertinoIcons.group_solid,
              CupertinoColors.systemTeal,
            ),
          ]),
        ),
        SliverToBoxAdapter(
          child: _buildSection('Quick Actions'),
        ),
        SliverToBoxAdapter(
          child: CupertinoListSection.insetGrouped(
              backgroundColor: CupertinoColors.systemGroupedBackground,
              children: [
                _buildActionItem('Add New Appointment', CupertinoIcons.calendar_badge_plus),
                _buildActionItem('Create Report', CupertinoIcons.chart_bar_fill),
                _buildActionItem('Send Invoice', CupertinoIcons.doc_text_fill),
              ],
            ),
          
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.label,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey6,
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
                // ignore: deprecated_member_use
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
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle, IconData icon, Color color) {
    return CupertinoListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
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
        style: const TextStyle(decoration: TextDecoration.none),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(decoration: TextDecoration.none),
      ),
      trailing: const CupertinoListTileChevron(),
      onTap: () {},
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
