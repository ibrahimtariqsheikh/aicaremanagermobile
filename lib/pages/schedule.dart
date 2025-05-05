import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:aicaremanagermob/models/schedule.dart';
import 'package:aicaremanagermob/pages/appointment_details_page.dart';
import 'package:aicaremanagermob/widgets/custom_card.dart';
import 'dart:math';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final schedules = authState.schedules;
    final theme = Theme.of(context);
    
    // Process schedules
    final processedSchedules = _processSchedules(schedules);
    final upcomingSchedules = processedSchedules.item1;
    final finishedSchedules = processedSchedules.item4;
    
    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.cardColor.withValues(alpha: 0.9),
        border: null,
        middle: Text(
          'Schedule',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.calendar, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                'Filter',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          onPressed: () {
            _showFilterOptions(context);
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Filter tabs
            _buildFilterTabs(context, upcomingSchedules.length, finishedSchedules.length),
            
            // Schedule list
            Expanded(
              child: upcomingSchedules.isEmpty
                  ? _buildEmptyState(context)
                  : _buildScheduleList(context, upcomingSchedules, authState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, int upcomingCount, int finishedCount) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Upcoming($upcomingCount)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(CupertinoIcons.chevron_down, size: 16, color: theme.colorScheme.primary),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.calendar_badge_minus,
            size: 70,
            color: theme.colorScheme.onTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming appointments',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your schedule is clear for now',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(BuildContext context, List<Schedule> schedules, dynamic authState) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildScheduleCard(context, schedule, authState),
        );
      },
    );
  }

  Widget _buildScheduleCard(BuildContext context, Schedule schedule, dynamic authState) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AppointmentDetailsPage(schedule: schedule),
          ),
        );
      },
      child: CustomCard(
        hasShadow: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(schedule.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      schedule.status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(schedule.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
               
                ],
              ),
              const SizedBox(height: 12),
              // Client info
              Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(schedule.client?.fullName ?? 'Client'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.client?.fullName ?? 'Client',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dateFormat.format(schedule.date)} at ${timeFormat.format(DateFormat('HH:mm').parse(schedule.startTime))}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      schedule.type.toString().split('.').last,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  void _showFilterOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.systemBackground,
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    onSelectedItemChanged: (int index) {
                      // Handle filter selection
                    },
                    children: const [
                      Text('All Appointments'),
                      Text('Today'),
                      Text('This Week'),
                      Text('This Month'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Process and organize schedules
  Tuple4<List<Schedule>, Map<String, List<Schedule>>, List<String>, List<Schedule>> _processSchedules(List<Schedule> schedules) {
    // Sort schedules by date and time
    final sortedSchedules = List<Schedule>.from(schedules)
      ..sort((a, b) {
        final dateComparison = a.date.compareTo(b.date);
        return dateComparison == 0 ? a.startTime.compareTo(b.startTime) : dateComparison;
      });
    
    final now = DateTime.now();
    
    // Filter future schedules
    final upcomingSchedules = sortedSchedules.where((schedule) {
      return schedule.date.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();
    
    // Filter past schedules
    final finishedSchedules = sortedSchedules.where((schedule) {
      return schedule.date.isBefore(now) && schedule.status != 'CANCELLED';
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
    
    return Tuple4(upcomingSchedules, groupedSchedules, sortedDates, finishedSchedules);
  }
}

// Helper class for returning multiple values
class Tuple4<T1, T2, T3, T4> {
  final T1 item1;
  final T2 item2;
  final T3 item3;
  final T4 item4;

  Tuple4(this.item1, this.item2, this.item3, this.item4);
}