import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aicaremanagermob/models/schedule.dart';
import 'package:aicaremanagermob/models/user.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:aicaremanagermob/pages/visit_checkin_page.dart';
import 'package:aicaremanagermob/widgets/custom_card.dart';
import 'dart:math';


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
  final List<String> _tabs = ['Overview', 'Client Details', 'Notes'];

  @override
  Widget build(BuildContext context) {
    final client = widget.schedule.client;
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(widget.schedule.date);
    final isToday = DateFormat('yyyy-MM-dd').format(widget.schedule.date) == 
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
    final theme = Theme.of(context);
    
    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.cardColor.withValues(alpha: 0.9),
        border: null,
        middle: Text(
          'Appointment Details',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.pencil, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                'Edit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Appointment Header Card
            _buildAppointmentHeader(context, client, formattedDate, isToday),
            
            // Tab Selector
            _buildTabSelector(),
            
            // Tab Content
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
    final theme = Theme.of(context);
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
                HapticFeedback.selectionClick();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text(
                    _tabs[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? theme.colorScheme.surface : theme.colorScheme.onTertiary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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
        return _buildNotesTab();
      default:
        return _buildOverviewTab(client);
    }
  }

  Widget _buildOverviewTab(User? client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Client Basic Information
        _buildSectionHeader('Client Information'),
        _buildClientBasicInfoCard(client),
        
        // Action Buttons
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
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Client information not available'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information
        _buildSectionHeader('Personal Information'),
        _buildPersonalInfoCard(client),
        
        // Contact Information
        _buildSectionHeader('Contact Information'),
        _buildContactInfoCard(client),
        
        // Medical Information
        _buildSectionHeader('Medical Information'),
        _buildMedicalInfoCard(client),
        
        // Preferences & Notes
        _buildSectionHeader('Preferences & Background'),
        _buildPreferencesCard(client),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNotesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appointment Notes
        _buildSectionHeader('Appointment Notes'),
        _buildNotesCard(),
        
        // Add Notes Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // Handle add notes
              HapticFeedback.mediumImpact();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.activeBlue,
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.pencil, color: CupertinoColors.activeBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Add Notes',
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.bold,
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

  Widget _buildAppointmentHeader(BuildContext context, User? client, String formattedDate, bool isToday) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(widget.schedule.status);
    final appointmentType = widget.schedule.type.toString().split('.').last;
    
    return CustomCard(
      hasShadow: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and ID
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.schedule.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '#RSV${10000 + _getIdNumericValue(widget.schedule.id)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Client info
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(client?.fullName ?? 'Client'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client?.fullName ?? 'Client',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isToday ? 'Today' : formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointmentType,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.clock,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.schedule.startTime} - ${widget.schedule.endTime}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _calculateDuration(widget.schedule.startTime, widget.schedule.endTime),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiary,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomCard(
        hasShadow: false,
        child: child,
      ),
    );
  }

  Widget _buildClientBasicInfoCard(User? client) {
    if (client == null) {
      return _buildCard(
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Client information not available'),
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
              CupertinoIcons.person,
              'Client ID',
              value: client.id,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.mail,
              'Email',
              value: client.email,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.phone,
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
              CupertinoIcons.person_2,
              'Full Name',
              value: client.fullName,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.calendar,
              'Date of Birth',
              value: client.dateOfBirth?.toString() ?? 'Not provided',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.heart,
              'Gender',
              value: client.subRole?.toString().split('.').last ?? 'Not provided',
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
              CupertinoIcons.location,
              'Address',
              value: client.address ?? 'Not provided',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.phone,
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
              CupertinoIcons.heart_circle,
              'Medical Conditions',
              value: client.history ?? 'None reported',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.exclamationmark_circle,
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
              CupertinoIcons.star,
              'Preferences',
              value: client.likesDislikes ?? 'None specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.doc_text,
              'Background',
              value: client.history ?? 'None provided',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    final hasNotes = widget.schedule.notes != null && widget.schedule.notes!.isNotEmpty;
    
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
                          color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_text,
                          color: CupertinoColors.activeBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Appointment Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.schedule.notes!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No notes available for this appointment',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
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
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(User? client) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Primary action button (confirm/cancel)
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Handle confirm/cancel
            HapticFeedback.mediumImpact();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: widget.schedule.status == 'CONFIRMED' 
                ? CupertinoColors.systemRed 
                : CupertinoColors.activeGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.schedule.status == 'CONFIRMED' 
                  ? 'Cancel Appointment' 
                  : 'Confirm Appointment',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Check-in button
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => VisitCheckinPage(schedule: widget.schedule),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.checkmark_circle, color: theme.colorScheme.surface, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Check In',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';
    
    final nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  int _getIdNumericValue(String id) {
    final numericPart = id.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericPart.isEmpty) return 0;
    return int.parse(numericPart.substring(0, min(2, numericPart.length)));
  }

  String _calculateDuration(String startTime, String endTime) {
    final start = DateFormat('HH:mm').parse(startTime);
    final end = DateFormat('HH:mm').parse(endTime);
    final difference = end.difference(start);
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}