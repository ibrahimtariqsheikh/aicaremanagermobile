import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:aicaremanagermob/widgets/custom_loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:aicaremanagermob/models/user.dart' as app_user;
import 'package:aicaremanagermob/providers/message_user_provider.dart';
import 'package:aicaremanagermob/utils/image_utils.dart';
import 'package:aicaremanagermob/models/message_data.dart';

class ChatUser {
  final String id;
  final String firstname;
  final String lastname;
  final DateTime lastMessageTime;
  final String? lastMessage;

  ChatUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.lastMessageTime,
    this.lastMessage,
  });
}

class CustomTabBar extends StatelessWidget {
  final UserRoleTab selectedTab;
  final Function(UserRoleTab) onTabSelected;

  const CustomTabBar({
    Key? key,
    required this.selectedTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTab(
            context,
            UserRoleTab.clients,
            'Clients',
          ),
          _buildTab(
            context,
            UserRoleTab.careWorkers,
            'Care Workers',
          ),
          _buildTab(
            context,
            UserRoleTab.officeStaff,
            'Office Staff',
          ),
          _buildTab(
            context,
            UserRoleTab.all,
            'All',
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    UserRoleTab tab,
    String label,
  ) {
    final isSelected = selectedTab == tab;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(tab),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(messageUsersNotifierProvider.notifier).loadMessageUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageUsersState = ref.watch(messageUsersNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Messages',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh, size: 20),
            onPressed: () {
              ref
                  .read(messageUsersNotifierProvider.notifier)
                  .loadMessageUsers();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomTabBar(
              selectedTab: messageUsersState.selectedTab,
              onTabSelected: (tab) {
                ref
                    .read(messageUsersNotifierProvider.notifier)
                    .setSelectedTab(tab);
              },
            ),
            Expanded(
              child: messageUsersState.isLoading
                  ? const Center(child: CustomLoadingIndicator())
                  : messageUsersState.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.exclamationmark_circle,
                                color: Colors.red,
                                size: 40,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading users',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                child: Text(
                                  'Try Again',
                                  style: GoogleFonts.inter(),
                                ),
                                onPressed: () {
                                  ref
                                      .read(
                                          messageUsersNotifierProvider.notifier)
                                      .loadMessageUsers();
                                },
                              ),
                            ],
                          ),
                        )
                      : _buildUsersList(
                          messageUsersState.filteredUsers,
                          messageUsersState.selectedTab
                              .toString()
                              .split('.')
                              .last,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(List<app_user.User> users, String userType) {
    return users.isEmpty
        ? _buildEmptyState(userType)
        : ListView.builder(
            key: ValueKey(userType),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserItem(context, user);
            },
          );
  }

  Widget _buildEmptyState(String userType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chat_bubble_2,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No $userType found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When $userType are added to your agency, they will appear here',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, app_user.User user) {
    // Generate avatar URL based on user id for consistency
// Max avatar index is 70

    final authState = ref.read(authProvider);

    // Parse the color from API if available or use default blue
    Color userColor = Colors.blue;
    if (user.color != null && user.color!.startsWith('#')) {
      try {
        userColor = Color(
            int.parse(user.color!.substring(1, 7), radix: 16) + 0xFF000000);
      } catch (e) {
        // Use default color if parsing fails
      }
    }

    // Get role display name
    String roleDisplay = 'User';
    switch (user.role) {
      case app_user.Role.CLIENT:
        roleDisplay = 'Client';
        break;
      case app_user.Role.CARE_WORKER:
        roleDisplay = 'Care Worker';
        break;
      case app_user.Role.OFFICE_STAFF:
        roleDisplay = 'Office Staff';
        break;
      case app_user.Role.ADMIN:
        roleDisplay = 'Admin';
        break;
      case app_user.Role.SOFTWARE_OWNER:
        roleDisplay = 'Owner';
        break;
      default:
        roleDisplay = 'User';
    }

    // Mock last message for now - this should come from your chat provider
    const lastMessage = 'Hello, how are you?';

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ChatScreen(
              messageData: MessageData(
                role: user.role == app_user.Role.CLIENT
                    ? Role.CLIENT
                    : user.role == app_user.Role.CARE_WORKER
                        ? Role.CARE_WORKER
                        : user.role == app_user.Role.OFFICE_STAFF
                            ? Role.OFFICE_STAFF
                            : user.role == app_user.Role.ADMIN
                                ? Role.ADMIN
                                : Role.SOFTWARE_OWNER,
                username: user.fullName,
                message: lastMessage,
                createdAt: DateTime.now(),
                senderID: authState.user.id,
                receiverID: user.id,
                urlAvatar: ImageUtils.getRandomPlaceholderImage(),
                clientId: user.role == app_user.Role.CLIENT ? user.id : null,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            ClipOval(
              child: ImageUtils.getPlaceholderImage(
                width: 56,
                height: 56,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: userColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.subRole != null
                    ? _formatSubRole(user.subRole.toString())
                    : roleDisplay,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: userColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSubRole(String subRole) {
    // Convert from 'SubRole.FINANCE_MANAGER' to 'Finance Manager'
    final type = subRole.split('.').last;
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
