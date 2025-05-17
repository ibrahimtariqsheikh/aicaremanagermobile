import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aicaremanagermob/main.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aicaremanagermob/pages/oboarding/sign_in_page.dart';
import 'package:aicaremanagermob/utils/image_utils.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(ref, theme),
                ),
                SliverToBoxAdapter(
                  child: _buildPersonalInfoSection(ref, theme),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildLogoutSection(ref, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(WidgetRef ref, ThemeData theme) {
    final user = ref.watch(authProvider).user;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: AppColors.mainBlue.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                ImageUtils.getRandomPlaceholderImage(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mainBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.toString().split('.').last,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.mainBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(WidgetRef ref, ThemeData theme) {
    final user = ref.watch(authProvider).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Personal Information',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dividerLight, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem(
                  'Phone', user.phoneNumber, LucideIcons.phone, theme),
              _buildInfoItem(
                  'Address',
                  '${user.address}, ${user.city}, ${user.province}',
                  LucideIcons.mapPin,
                  theme),
              _buildInfoItem(
                  'Postal Code', user.postalCode, LucideIcons.mail, theme),
              _buildInfoItem(
                  'Date of Birth',
                  user.dateOfBirth?.toIso8601String(),
                  LucideIcons.calendar,
                  theme),
              _buildInfoItem(
                  'Languages', user.languages, LucideIcons.languages, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutSection(WidgetRef ref, ThemeData theme) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: AppColors.mainBlue,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.logOut,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            'Log Out',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      onPressed: () {
        ref.read(authProvider.notifier).signOut();
        Navigator.of(ref.context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SignInPage(),
            fullscreenDialog: true,
            maintainState: false,
          ),
          (route) => false,
        );
      },
    );
  }

  Widget _buildInfoItem(
      String title, String? value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not specified',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
