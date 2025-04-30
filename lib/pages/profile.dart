import 'package:flutter/cupertino.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CupertinoListSection.insetGrouped(
              backgroundColor: CupertinoColors.systemGroupedBackground,
              children: [
                _buildActionItem('Edit Profile', CupertinoIcons.person_fill),
                _buildActionItem('Change Password', CupertinoIcons.lock_fill),
                _buildActionItem('Log Out', CupertinoIcons.power),
                _buildActionItem('Toggle Theme', CupertinoIcons.gear),
              ],
            ),
        
        ),
      ],
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
