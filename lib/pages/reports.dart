import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'report_details.dart';

// Simple Report model based on completed schedules
class Report {
  final String id;
  final String clientName;
  final DateTime date;
  final String visitType;
  final String duration;
  final String status;
  final String? notes;
  final String? address;

  Report({
    required this.id,
    required this.clientName,
    required this.date,
    required this.visitType,
    required this.duration,
    required this.status,
    this.notes,
    this.address,
  });
}

// Sample reports provider
final reportsProvider = StateProvider<List<Report>>((ref) {
  // This would normally be loaded from an API
  return [
    Report(
      id: '1',
      clientName: 'Maria Johnson',
      date: DateTime.now().subtract(const Duration(days: 1)),
      visitType: 'HOME_VISIT',
      duration: '1h 15m',
      status: 'COMPLETED',
      notes:
          'Client is showing improvement in mobility. Medication adherence is good.',
      address: '123 Main St, Apt 4B, New York, NY 10001',
    ),
    Report(
      id: '2',
      clientName: 'Robert Smith',
      date: DateTime.now().subtract(const Duration(days: 2)),
      visitType: 'WEEKLY_CHECKUP',
      duration: '45m',
      status: 'COMPLETED',
      notes: 'Blood pressure readings normal. Exercise plan updated.',
      address: '456 Park Ave, New York, NY 10022',
    ),
    Report(
      id: '3',
      clientName: 'Eliza Rodriguez',
      date: DateTime.now().subtract(const Duration(days: 3)),
      visitType: 'EMERGENCY',
      duration: '2h 05m',
      status: 'COMPLETED',
      notes: 'Fall incident. No serious injuries but will need follow-up.',
      address: '789 Broadway, New York, NY 10003',
    ),
    Report(
      id: '4',
      clientName: 'James Wilson',
      date: DateTime.now().subtract(const Duration(days: 4)),
      visitType: 'HOME_VISIT',
      duration: '1h 30m',
      status: 'COMPLETED',
      notes:
          'Medication review completed. Added new prescription for hypertension.',
      address: '321 1st Ave, New York, NY 10009',
    ),
    Report(
      id: '5',
      clientName: 'Emma Davis',
      date: DateTime.now().subtract(const Duration(days: 5)),
      visitType: 'ROUTINE',
      duration: '1h',
      status: 'COMPLETED',
      notes: 'Vital signs stable. Discussed nutrition plan.',
      address: '654 5th Ave, New York, NY 10022',
    ),
  ];
});

// Filter options
enum ReportFilter { recent, thisWeek, lastWeek, thisMonth }

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  ReportFilter _selectedFilter = ReportFilter.recent;

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportsProvider);

    // Filter reports based on selected filter
    final List<Report> filteredReports = _filterReports(reports);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Visit Reports',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.search,
                size: 20, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.ellipsis_circle,
                size: 20, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: filteredReports.isEmpty
                ? _buildEmptyState()
                : _buildReportsList(filteredReports),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(ReportFilter.recent, 'Recent'),
                const SizedBox(width: 8),
                _buildFilterChip(ReportFilter.thisWeek, 'This Week'),
                const SizedBox(width: 8),
                _buildFilterChip(ReportFilter.lastWeek, 'Last Week'),
                const SizedBox(width: 8),
                _buildFilterChip(ReportFilter.thisMonth, 'This Month'),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.black12, thickness: 0.3),
      ],
    );
  }

  Widget _buildFilterChip(ReportFilter filter, String label) {
    final isSelected = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CupertinoColors.systemBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? CupertinoColors.systemBlue : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.doc_text,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete visits to generate reports',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(List<Report> reports) {
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportItem(report);
      },
    );
  }

  Widget _buildReportItem(Report report) {
    return GestureDetector(
      onTap: () {
        _navigateToReportDetails(report);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(report.status),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getVisitTypeIcon(report.visitType),
                    size: 16,
                    color: _getStatusColor(report.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(report.date),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(' • ',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              )),
                          Text(
                            report.duration,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        report.clientName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (report.address != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.location,
                                size: 14, color: Colors.black54),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                report.address!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getVisitTypeBackgroundColor(report.visitType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatVisitType(report.visitType),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _getVisitTypeColor(report.visitType),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12, thickness: 0.3),
        ],
      ),
    );
  }

  void _navigateToReportDetails(Report report) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ReportDetailsPage(report: report),
      ),
    );
  }

  List<Report> _filterReports(List<Report> reports) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case ReportFilter.recent:
        return reports.take(5).toList();
      case ReportFilter.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return reports
            .where((report) => report.date.isAfter(startOfWeek))
            .toList();
      case ReportFilter.lastWeek:
        final startOfLastWeek =
            today.subtract(Duration(days: today.weekday + 6));
        final endOfLastWeek = today.subtract(Duration(days: today.weekday));
        return reports
            .where((report) =>
                report.date.isAfter(startOfLastWeek) &&
                report.date.isBefore(endOfLastWeek))
            .toList();
      case ReportFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return reports
            .where((report) => report.date.isAfter(startOfMonth))
            .toList();
    }
  }

  String _formatVisitType(String visitType) {
    return visitType
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  IconData _getVisitTypeIcon(String visitType) {
    switch (visitType.toUpperCase()) {
      case 'HOME_VISIT':
        return CupertinoIcons.home;
      case 'APPOINTMENT':
        return CupertinoIcons.calendar;
      case 'WEEKLY_CHECKUP':
        return CupertinoIcons.chart_bar;
      case 'CHECKUP':
        return CupertinoIcons.doc_checkmark;
      case 'EMERGENCY':
        return CupertinoIcons.exclamationmark_triangle;
      case 'ROUTINE':
        return CupertinoIcons.repeat;
      default:
        return CupertinoIcons.doc_text;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF2196F3); // Material Blue
      case 'CANCELED':
        return const Color(0xFFE53935); // Material Red
      case 'PENDING':
        return const Color(0xFF2196F3); // Material Blue
      case 'CONFIRMED':
        return const Color(0xFF2196F3); // Material Blue
      default:
        return const Color(0xFF2196F3); // Material Blue
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFFE3F2FD); // Light Blue
      case 'CANCELED':
        return const Color(0xFFFFEBEE); // Light Red
      case 'PENDING':
        return const Color(0xFFE3F2FD); // Light Blue
      case 'CONFIRMED':
        return const Color(0xFFE3F2FD); // Light Blue
      default:
        return const Color(0xFFE3F2FD); // Light Blue
    }
  }

  Color _getVisitTypeColor(String visitType) {
    switch (visitType.toUpperCase()) {
      case 'HOME_VISIT':
        return const Color(0xFF4CAF50); // Material Green
      case 'APPOINTMENT':
        return const Color(0xFF9C27B0); // Material Purple
      case 'WEEKLY_CHECKUP':
        return const Color(0xFF2196F3); // Material Blue
      case 'CHECKUP':
        return const Color(0xFF00BCD4); // Material Cyan
      case 'EMERGENCY':
        return const Color(0xFFE53935); // Material Red
      case 'ROUTINE':
        return const Color(0xFFFF9800); // Material Orange
      default:
        return const Color(0xFF2196F3); // Material Blue
    }
  }

  Color _getVisitTypeBackgroundColor(String visitType) {
    switch (visitType.toUpperCase()) {
      case 'HOME_VISIT':
        return const Color(0xFFE8F5E9); // Light Green
      case 'APPOINTMENT':
        return const Color(0xFFF3E5F5); // Light Purple
      case 'WEEKLY_CHECKUP':
        return const Color(0xFFE3F2FD); // Light Blue
      case 'CHECKUP':
        return const Color(0xFFE0F7FA); // Light Cyan
      case 'EMERGENCY':
        return const Color(0xFFFFEBEE); // Light Red
      case 'ROUTINE':
        return const Color(0xFFFFF3E0); // Light Orange
      default:
        return const Color(0xFFE3F2FD); // Light Blue
    }
  }
}
