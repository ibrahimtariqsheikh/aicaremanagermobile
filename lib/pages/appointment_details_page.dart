import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:aicaremanagermob/utils/image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aicaremanagermob/models/schedule.dart';
import 'package:aicaremanagermob/models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:aicaremanagermob/pages/visit_checkin_page.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final Schedule schedule;

  const AppointmentDetailsPage({
    super.key,
    required this.schedule,
  });

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Overview', 'Client Details', 'History'];

  @override
  Widget build(BuildContext context) {
    final client = widget.schedule.client;
    final formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(widget.schedule.date);
    final isToday = DateUtils.isSameDay(widget.schedule.date, DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft,
              color: CupertinoColors.systemGrey, size: 16),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text(
          'Appointment Details',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabSelector(),
            _buildAppointmentHeader(context, client, formattedDate, isToday),
            Expanded(
              child: CupertinoScrollbar(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: _buildSelectedTabContent(client),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: AppColors.cardColor,
          child: CupertinoSlidingSegmentedControl<String>(
            backgroundColor: AppColors.cardColor,
            thumbColor: CupertinoColors.white,
            groupValue: _tabs[_selectedTabIndex],
            onValueChanged: (value) {
              setState(() {
                _selectedTabIndex = _tabs.indexOf(value ?? '');
              });
            },
            children: {
              for (var tab in _tabs)
                tab: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    tab,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _selectedTabIndex == _tabs.indexOf(tab)
                          ? CupertinoColors.black
                          : CupertinoColors.inactiveGray,
                    ),
                  ),
                ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(User? client) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab(client);
      case 1:
        return _buildClientDetailsTab(client);
      case 2:
        return _buildHistoryTab();
      default:
        return _buildOverviewTab(client);
    }
  }

  Widget _buildOverviewTab(User? client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Client Basic Information
        _buildSectionHeader('Overview'),
        _buildClientBasicInfoCard(client),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _buildActionButtons(client),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildClientDetailsTab(User? client) {
    if (client == null) {
      return _buildCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Client information not available',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Information'),
        _buildPersonalInfoCard(client),
        _buildSectionHeader('Contact Information'),
        _buildContactInfoCard(client),
        _buildSectionHeader('Medical Information'),
        _buildMedicalInfoCard(client),
        _buildSectionHeader('Preferences & Background'),
        _buildPreferencesCard(client),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appointment History
        _buildSectionHeader('Appointment History'),
        _buildHistoryCard(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // Handle add history
              HapticFeedback.mediumImpact();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.mainBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plus, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Add History',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHistoryCard() {
    final dummyHistory = [
      {
        'date': 'March 15, 2024',
        'type': 'Regular Check-up',
        'status': 'Completed',
        'notes':
            'Client reported feeling better. Medication adjusted as per doctor\'s recommendation.',
        'time': '10:00 AM - 11:00 AM',
      },
      {
        'date': 'February 28, 2024',
        'type': 'Follow-up',
        'status': 'Completed',
        'notes':
            'Follow-up appointment for medication review. Client showing good progress.',
        'time': '2:30 PM - 3:30 PM',
      },
      {
        'date': 'February 15, 2024',
        'type': 'Initial Consultation',
        'status': 'Completed',
        'notes': 'Initial assessment completed. Care plan established.',
        'time': '11:00 AM - 12:00 PM',
      },
    ];

    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dummyHistory.isNotEmpty)
              Column(
                children: dummyHistory.map((history) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.mainBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              LucideIcons.history,
                              color: AppColors.mainBlue,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      history['type']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        history['status']!,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  history['date']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  history['time']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    history['notes']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (history != dummyHistory.last)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            color: AppColors.dividerLight,
                            height: 1,
                          ),
                        ),
                    ],
                  );
                }).toList(),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No history available for this client',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentHeader(
      BuildContext context, User? client, String formattedDate, bool isToday) {
    final appointmentType = widget.schedule.type.toString().split('.').last;

    return Container(
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 0,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  ImageUtils.getRandomPlaceholderImage(),
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client?.fullName ?? 'Client',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isToday ? 'Today' : formattedDate,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    appointmentType[0].toUpperCase() +
                        appointmentType.substring(1),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Time and duration
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.clock,
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
                        'Time',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textFaded,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${_formatTime(widget.schedule.startTime)} - ${_formatTime(widget.schedule.endTime)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _calculateDuration(
                      widget.schedule.startTime, widget.schedule.endTime),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.dividerLight, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }

  Widget _buildClientBasicInfoCard(User? client) {
    if (client == null) {
      return _buildCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Client information not available',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              LucideIcons.user,
              'Client ID',
              value: client.id,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              LucideIcons.mail,
              'Email',
              value: client.email,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              LucideIcons.phone,
              'Phone',
              value: client.phoneNumber ?? 'Not provided',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(User client) {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              LucideIcons.user,
              'Full Name',
              value: client.fullName,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              LucideIcons.calendar,
              'Date of Birth',
              value: client.dateOfBirth != null
                  ? DateFormat('MMMM d, yyyy').format(client.dateOfBirth!)
                  : 'Not provided',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              LucideIcons.badge,
              'Role',
              value: _formatSubRole(client.subRole?.toString().split('.').last),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(User client) {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              LucideIcons.mapPin,
              'Address',
              value: client.address ?? 'Not provided',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              LucideIcons.phone,
              'Emergency Contact',
              value: client.phoneNumber ?? 'Not provided',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoCard(User client) {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              LucideIcons.heart,
              'Medical Conditions',
              value: client.history ?? 'None reported',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              LucideIcons.alertTriangle,
              'Allergies',
              value: client.allergies ?? 'None reported',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(User client) {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              LucideIcons.star,
              'Preferences',
              value: client.likesDislikes ?? 'None specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              LucideIcons.fileText,
              'Background',
              value: client.history ?? 'None provided',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    final hasNotes =
        widget.schedule.notes != null && widget.schedule.notes!.isNotEmpty;

    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasNotes)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.mainBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.fileText,
                          color: AppColors.mainBlue,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Appointment Notes',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.schedule.notes!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No notes available for this appointment',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, {required String value}) {
    return Row(
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
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textFaded,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(User? client) {
    return Column(
      children: [
        // CupertinoButton(
        //   padding: EdgeInsets.zero,
        //   onPressed: () {
        //     HapticFeedback.mediumImpact();
        //   },
        //   child: Container(
        //     width: double.infinity,
        //     padding: const EdgeInsets.symmetric(vertical: 14),
        //     decoration: BoxDecoration(
        //       color: widget.schedule.status == 'CONFIRMED'
        //           ? const Color(0xFFE53935)
        //           : const Color(0xFF4CAF50),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: Center(
        //       child: Text(
        //         widget.schedule.status == 'CONFIRMED'
        //             ? 'Cancel Appointment'
        //             : 'Confirm Appointment',
        //         style: GoogleFonts.inter(
        //           fontSize: 14,
        //           color: Colors.white,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),

        const SizedBox(height: 12),

        // Check-in button
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    VisitCheckinPage(schedule: widget.schedule),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.mainBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.checkCircle,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  widget.schedule.hasAssignedTasks
                      ? 'Clock in Visit'
                      : 'Clock in Visit',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time;
    }
  }

  String _calculateDuration(String startTime, String endTime) {
    try {
      final start = DateFormat('HH:mm').parse(startTime);
      final end = DateFormat('HH:mm').parse(endTime);
      final difference = end.difference(start);

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${minutes}m';
    } catch (e) {
      return '';
    }
  }

  String _formatSubRole(String? subRole) {
    if (subRole == null) return 'Not provided';
    return subRole
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
