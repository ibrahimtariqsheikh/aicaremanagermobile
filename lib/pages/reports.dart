// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/widgets/custom_card.dart';
import 'package:aicaremanagermob/pages/visit_report_details.dart';
import 'package:intl/intl.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'Last Month', 'This Year'];

  // Dummy data for completed visits
  final List<Map<String, dynamic>> _completedVisits = [
    {
      'clientName': 'John Smith',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'Home Visit',
      'duration': '1h 30m',
      'mood': 'Good',
      'healthStatus': 'Stable',
      'notes': 'Regular check-up completed. Client is doing well with their medication routine.',
    },
    {
      'clientName': 'Mary Johnson',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'Office Appointment',
      'duration': '45m',
      'mood': 'Excellent',
      'healthStatus': 'Improving',
      'notes': 'Follow-up appointment. Client reported significant improvement in mobility.',
    },
    {
      'clientName': 'Robert Brown',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'type': 'Home Visit',
      'duration': '2h 15m',
      'mood': 'Fair',
      'healthStatus': 'Stable',
      'notes': 'Extended visit due to medication review. Client needs additional support with daily activities.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.cardColor.withValues(alpha: 0.9),
        border: null,
        middle: Text(
          'Visit Reports',
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
                _selectedPeriod,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          onPressed: () {
            _showPeriodPicker();
          },
        ),
      ),
      child: SafeArea(
        child: CupertinoScrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            itemCount: _completedVisits.length,
            itemBuilder: (context, index) {
              final visit = _completedVisits[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildVisitListItem(visit),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVisitListItem(Map<String, dynamic> visit) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => VisitReportDetails(visit: visit),
          ),
        );
      },
      child: CustomCard(
        hasShadow: false,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    _getInitials(visit['clientName']),
                    style: theme.textTheme.bodyMedium?.copyWith(
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            visit['clientName'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            visit['type'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 12,
                          color: theme.colorScheme.onTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dateFormat.format(visit['date'])} at ${timeFormat.format(visit['date'])} • ${visit['duration']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(
                          theme,
                          icon: CupertinoIcons.heart_circle,
                          label: visit['mood'],
                          color: _getMoodColor(visit['mood']),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          theme,
                          icon: CupertinoIcons.heart,
                          label: visit['healthStatus'],
                          color: _getHealthStatusColor(visit['healthStatus']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chevron
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: theme.colorScheme.onTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'improving':
        return Colors.green;
      case 'stable':
        return Colors.blue;
      case 'declining':
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

  void _showPeriodPicker() {
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
                      setState(() {
                        _selectedPeriod = _periods[index];
                      });
                    },
                    children: _periods.map((String period) {
                      return Center(child: Text(period));
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}