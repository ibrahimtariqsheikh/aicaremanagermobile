import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aicaremanagermob/models/schedule.dart';
import 'package:aicaremanagermob/models/user.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
// ignore: unnecessary_import
import 'dart:ui';

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
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.9),
        border: null,
        middle: const Text(
          'Appointment Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.pencil, size: 16),
              SizedBox(width: 4),
              Text('Edit'),
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
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
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
                  color: isSelected ? CupertinoColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: CupertinoColors.systemGrey5.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                margin: const EdgeInsets.all(4),
                child: Center(
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
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
    final statusColor = _getStatusColor(widget.schedule.status);
    final appointmentType = widget.schedule.type.toString().split('.').last;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status indicator at the top
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client info row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildClientAvatar(client),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client?.fullName ?? 'Unknown Client',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          if (client?.preferredName != null)
                            Text(
                              'Preferred name: ${client!.preferredName}',
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 14,
                              ),
                            )
                          else if (client?.subRole != null)
                            Text(
                              _formatSubRole(client!.subRole!),
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(widget.schedule.status),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                
                // Date and time info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        CupertinoIcons.calendar,
                        isToday ? 'Today' : formattedDate,
                        iconColor: CupertinoColors.activeBlue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        CupertinoIcons.clock,
                        '${widget.schedule.startTime} - ${widget.schedule.endTime}',
                        iconColor: CupertinoColors.activeBlue,
                        subtitle: _calculateDuration(widget.schedule.startTime, widget.schedule.endTime),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        _getAppointmentTypeIcon(appointmentType),
                        _getAppointmentTypeLabel(appointmentType),
                        iconColor: CupertinoColors.activeBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          children: [
            _buildContactInfoItem(
              CupertinoIcons.mail,
              'Email',
              client.email,
              onTap: () {
                HapticFeedback.selectionClick();
              },
            ),
            
            if (client.phoneNumber != null)
              _buildContactInfoItem(
                CupertinoIcons.phone,
                'Phone',
                client.phoneNumber!,
                onTap: () {
                  HapticFeedback.selectionClick();
                },
                actionIcon: CupertinoIcons.phone_fill,
                actionColor: CupertinoColors.activeGreen,
              ),
            
            if (client.address != null && client.city != null)
              _buildContactInfoItem(
                CupertinoIcons.location,
                'Address',
                _formatAddress(client),
                onTap: () {
                  HapticFeedback.selectionClick();
                },
                actionIcon: CupertinoIcons.map,
                actionColor: CupertinoColors.systemBlue,
              ),
            
            if (client.allergies != null && client.allergies != 'None')
              _buildInfoItem(
                CupertinoIcons.exclamationmark_triangle,
                'Allergies',
                client.allergies!,
                isWarning: true,
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
          children: [
            if (client.dateOfBirth != null)
              _buildInfoItem(
                CupertinoIcons.calendar,
                'Date of Birth',
                DateFormat('MMMM d, yyyy').format(client.dateOfBirth!),
                subtitle: '${_calculateAge(client.dateOfBirth!)} years old',
              ),
            
            if (client.languages != null)
              _buildInfoItem(
                CupertinoIcons.chat_bubble_2,
                'Languages',
                client.languages!,
              ),
              
            if (client.subRole != null)
              _buildInfoItem(
                CupertinoIcons.person,
                'Role',
                _formatSubRole(client.subRole!),
              ),
              
            if (client.nhsNumber != null)
              _buildInfoItem(
                CupertinoIcons.number,
                'NHS Number',
                client.nhsNumber!,
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
          children: [
            _buildInfoItem(
              CupertinoIcons.mail,
              'Email',
              client.email,
            ),
            
            if (client.phoneNumber != null)
              _buildInfoItem(
                CupertinoIcons.phone,
                'Phone',
                client.phoneNumber!,
              ),
            
            if (client.address != null)
              _buildInfoItem(
                CupertinoIcons.home,
                'Address',
                client.address!,
              ),
              
            if (client.city != null)
              _buildInfoItem(
                CupertinoIcons.location_circle,
                'City',
                client.city!,
              ),
              
            if (client.province != null)
              _buildInfoItem(
                CupertinoIcons.map,
                'Province',
                client.province!,
              ),
              
            if (client.postalCode != null)
              _buildInfoItem(
                CupertinoIcons.location_solid,
                'Postal Code',
                client.postalCode!,
              ),
              
            if (client.propertyAccess != null)
              _buildInfoItem(
                CupertinoIcons.lock,
                'Property Access',
                client.propertyAccess!,
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
          children: [
            if (client.allergies != null)
              _buildInfoItem(
                CupertinoIcons.exclamationmark_triangle,
                'Allergies',
                client.allergies!,
                isWarning: client.allergies != 'None',
              ),
              
            if (client.mobility != null)
              _buildInfoItem(
                CupertinoIcons.person_crop_circle_badge_checkmark,
                'Mobility',
                client.mobility!,
              ),
              
            _buildInfoItem(
              CupertinoIcons.exclamationmark_shield,
              'DNRA Order',
              client.dnraOrder == true ? 'Yes' : 'No',
              isWarning: client.dnraOrder == true,
            ),
              
            if (client.history != null)
              _buildInfoItem(
                CupertinoIcons.doc_text,
                'Medical History',
                client.history!,
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
          children: [
            if (client.likesDislikes != null)
              _buildInfoItem(
                CupertinoIcons.hand_thumbsup,
                'Likes & Dislikes',
                client.likesDislikes!,
              ),
              
            if (client.interests != null)
              _buildInfoItem(
                CupertinoIcons.star,
                'Interests',
                client.interests!,
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
                          color: CupertinoColors.activeBlue.withOpacity(0.1),
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
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.doc_text,
                    color: CupertinoColors.systemGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'No notes for this appointment',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(User? client) {
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.schedule.status == 'CONFIRMED' 
                  ? [CupertinoColors.systemRed, CupertinoColors.destructiveRed] 
                  : [CupertinoColors.activeGreen, CupertinoColors.systemGreen],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (widget.schedule.status == 'CONFIRMED' 
                    ? CupertinoColors.systemRed 
                    : CupertinoColors.activeGreen).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.schedule.status == 'CONFIRMED' 
                  ? 'Cancel Appointment' 
                  : 'Confirm Appointment',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary action buttons
        Row(
          children: [
            // Call client button
            if (client?.phoneNumber != null)
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Handle call
                    HapticFeedback.mediumImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.phone_fill, color: CupertinoColors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Call Client',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
            if (client?.phoneNumber != null)
              const SizedBox(width: 12),
              
            // Message client button
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  // Handle message
                  HapticFeedback.mediumImpact();
                },
                child: Container(
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
                      Icon(CupertinoIcons.chat_bubble_text, color: CupertinoColors.activeBlue, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Message',
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
          ],
        ),
      ],
    );
  }

  Widget _buildClientAvatar(User? client) {
    final initials = _getInitials(client?.fullName ?? '');
    final colors = [
      CupertinoColors.activeBlue,
      CupertinoColors.systemTeal,
      CupertinoColors.systemIndigo,
      CupertinoColors.systemPurple,
    ];
    
    // Generate a consistent color based on the client's name
    final colorIndex = client != null && client.fullName.isNotEmpty 
        ? client.fullName.codeUnitAt(0) % colors.length 
        : 0;
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[colorIndex],
            colors[colorIndex].withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors[colorIndex].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {
    Color iconColor = CupertinoColors.systemGrey, 
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {
    bool isWarning = false,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isWarning 
                ? CupertinoColors.systemOrange.withOpacity(0.1)
                : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon, 
              size: 16, 
              color: isWarning ? CupertinoColors.systemOrange : CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                    color: isWarning ? CupertinoColors.systemOrange : CupertinoColors.black,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoItem(IconData icon, String label, String value, {
    required VoidCallback onTap,
    IconData? actionIcon,
    Color? actionColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon, 
                size: 16, 
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ],
              ),
            ),
            if (actionIcon != null)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (actionColor ?? CupertinoColors.activeBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  actionIcon,
                  size: 16,
                  color: actionColor ?? CupertinoColors.activeBlue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';
    
    final nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  String _getAppointmentTypeLabel(String type) {
    switch (type) {
      case 'APPOINTMENT':
        return 'Office Appointment';
      case 'HOME_VISIT':
        return 'Home Visit';
      case 'CHECKUP':
        return 'Check-up';
      case 'EMERGENCY':
        return 'Emergency';
      case 'ROUTINE':
        return 'Routine Visit';
      default:
        return type.split('_').map((word) => 
          word.substring(0, 1).toUpperCase() + 
          word.substring(1).toLowerCase()
        ).join(' ');
    }
  }

  IconData _getAppointmentTypeIcon(String type) {
    switch (type) {
      case 'APPOINTMENT':
        return CupertinoIcons.doc_text;
      case 'HOME_VISIT':
        return CupertinoIcons.house;
      case 'CHECKUP':
        return CupertinoIcons.heart;
      case 'EMERGENCY':
        return CupertinoIcons.exclamationmark_triangle;
      case 'ROUTINE':
        return CupertinoIcons.calendar;
      default:
        return CupertinoIcons.calendar;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return CupertinoColors.activeGreen;
      case 'PENDING':
        return CupertinoColors.systemOrange;
      case 'CANCELLED':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String statusText;
    
    switch (status) {
      case 'CONFIRMED':
        badgeColor = CupertinoColors.activeGreen;
        statusText = 'Confirmed';
        break;
      case 'PENDING':
        badgeColor = CupertinoColors.systemOrange;
        statusText = 'Pending';
        break;
      case 'CANCELLED':
        badgeColor = CupertinoColors.systemRed;
        statusText = 'Cancelled';
        break;
      default:
        badgeColor = CupertinoColors.systemGrey;
        statusText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatSubRole(SubRole subRole) {
    switch (subRole) {
      case SubRole.serviceUser:
        return 'Service User';
      case SubRole.familyAndFriends:
        return 'Family & Friends';
      default:
        return subRole.toString().split('.').last.split('_').map((word) => 
          '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        ).join(' ');
    }
  }

  String _formatAddress(User client) {
    final addressParts = <String>[];
    
    if (client.address != null) {
      addressParts.add(client.address!);
    }
    
    if (client.city != null) {
      addressParts.add(client.city!);
    }
    
    if (client.province != null) {
      addressParts.add(client.province!);
    }
    
    if (client.postalCode != null) {
      addressParts.add(client.postalCode!);
    }
    
    return addressParts.join(', ');
  }

  String _calculateDuration(String startTime, String endTime) {
    try {
      final start = DateFormat('HH:mm').parse(startTime);
      final end = DateFormat('HH:mm').parse(endTime);
      final difference = end.difference(start);
      
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      if (hours > 0) {
        return '$hours hr${hours > 1 ? 's' : ''}${minutes > 0 ? ' $minutes min' : ''}';
      } else {
        return '$minutes min';
      }
    } catch (e) {
      return '';
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
}