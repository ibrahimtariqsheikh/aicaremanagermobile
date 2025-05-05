import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:aicaremanagermob/models/schedule.dart';
import 'package:aicaremanagermob/models/user.dart';
import 'package:aicaremanagermob/pages/appointment_details_page.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final schedules = authState.schedules;
    
    // Process schedules
    final processedSchedules = _processSchedules(schedules);
    final upcomingSchedules = processedSchedules.item1;
    final groupedSchedules = processedSchedules.item2;
    final sortedDates = processedSchedules.item3;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Schedule',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
            decoration: TextDecoration.none,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.calendar),
          onPressed: () {
            // Calendar functionality can be implemented here
            _showCalendarPicker(context);
          },
        ),
      ),
      child: SafeArea(
        child: upcomingSchedules.isEmpty
            ? _buildEmptyState()
            : _buildScheduleList(context, sortedDates, groupedSchedules),
      ),
    );
  }

  // Process and organize schedules
  Tuple3<List<Schedule>, Map<String, List<Schedule>>, List<String>> _processSchedules(List<Schedule> schedules) {
    // Sort schedules by date and time
    final sortedSchedules = List<Schedule>.from(schedules)
      ..sort((a, b) {
        final dateComparison = a.date.compareTo(b.date);
        return dateComparison == 0 ? a.startTime.compareTo(b.startTime) : dateComparison;
      });
    
    // Filter future schedules only
    final now = DateTime.now();
    final upcomingSchedules = sortedSchedules.where((schedule) {
      return schedule.date.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();
    
    // Group schedules by date
    Map<String, List<Schedule>> groupedSchedules = {};
    for (var schedule in upcomingSchedules) {
      final dateKey = DateFormat('yyyy-MM-dd').format(schedule.date);
      
      if (!groupedSchedules.containsKey(dateKey)) {
        groupedSchedules[dateKey] = [];
      }
      groupedSchedules[dateKey]!.add(schedule);
    }
    
    // Convert to sorted list of date entries
    final sortedDates = groupedSchedules.keys.toList()..sort();
    
    return Tuple3(upcomingSchedules, groupedSchedules, sortedDates);
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          CupertinoIcons.calendar_badge_minus,
          size: 70,
          color: CupertinoColors.systemGrey3,
        ),
        const SizedBox(height: 16),
        const Text(
          'No upcoming appointments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your schedule is clear for now',
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  // Schedule list widget
  Widget _buildScheduleList(BuildContext context, List<String> sortedDates, Map<String, List<Schedule>> groupedSchedules) {
    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dateSchedules = groupedSchedules[dateKey]!;
        final date = DateTime.parse(dateKey);
        final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date, isToday),
            ...dateSchedules.map((schedule) => _buildAppointmentCard(context, schedule)).toList(),
            const SizedBox(height: 8), // Add spacing between date groups
          ],
        );
      },
    );
  }

  // Date header widget
  Widget _buildDateHeader(DateTime date, bool isToday) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: CupertinoColors.systemGroupedBackground,
      child: Row(
        children: [
          Text(
            isToday ? 'Today' : DateFormat('EEEE, MMMM d').format(date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TODAY',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Appointment card widget
  Widget _buildAppointmentCard(BuildContext context, Schedule schedule) {
    final client = schedule.client;
    final startTime = schedule.startTime;
    final endTime = schedule.endTime;
    final status = schedule.status;
    final type = schedule.type.toString().split('.').last;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => AppointmentDetailsPage(
              schedule: schedule,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getAppointmentTypeIcon(type),
                            size: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getAppointmentTypeLabel(type),
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildClientAvatar(client?.fullName ?? 'Unknown'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              client?.fullName ?? 'Unknown Client',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.clock,
                            size: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$startTime - $endTime',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _calculateDuration(startTime, endTime),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Center(
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: CupertinoColors.systemGrey3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Client avatar widget
  Widget _buildClientAvatar(String fullName) {
    final initials = _getInitials(fullName);
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: CupertinoColors.activeBlue,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Status badge widget
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor, width: 0.5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Calendar picker dialog
  void _showCalendarPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 400,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime date) {
               
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
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
}

// Helper class for returning multiple values
class Tuple3<T1, T2, T3> {
  final T1 item1;
  final T2 item2;
  final T3 item3;

  Tuple3(this.item1, this.item2, this.item3);
}