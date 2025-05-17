// ignore_for_file: unused_element

import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aicaremanagermob/providers/report_provider.dart';
import 'package:aicaremanagermob/widgets/custom_loading_indicator.dart';
import 'package:aicaremanagermob/models/report.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aicaremanagermob/utils/image_utils.dart';
import 'report_details.dart';

// Filter options
enum ReportFilter { today, yesterday, thisWeek, thisMonth }

class ReportsPage extends ConsumerStatefulWidget {
  final String userId;

  const ReportsPage({super.key, required this.userId});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  ReportFilter _selectedFilter = ReportFilter.today;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Today', 'Yesterday', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(reportNotifierProvider.notifier)
          .loadReports(widget.userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error refreshing reports: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportNotifierProvider);
    final reports = reportState.reports;
    final isLoading = reportState.isLoading || _isLoading;
    final error = reportState.error;

    final List<Report> filteredReports = _filterReports(reports)
        .where((report) =>
            _searchQuery.isEmpty ||
            report.client.fullName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (report.client.address
                .toLowerCase()
                .contains(_searchQuery.toLowerCase())) ||
            (report.visitType?.name ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        middle: Text(
          'Reports',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(LucideIcons.search, size: 20, color: Colors.black54),
          onPressed: () {
            showSearch(
              context: context,
              delegate: ReportSearchDelegate(
                reports: reports,
                onReportSelected: (report) {
                  _navigateToReportDetails(report);
                },
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabSelector(),
            _buildDashboard(reports),
            Expanded(
              child: isLoading
                  ? const Center(child: CustomLoadingIndicator())
                  : error != null
                      ? _buildErrorState(error)
                      : filteredReports.isEmpty
                          ? _buildEmptyState()
                          : _buildReportsList(filteredReports),
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
                _selectedFilter = _getFilterFromTab(_selectedTabIndex);
              });
            },
            children: {
              for (var tab in _tabs)
                tab: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  ReportFilter _getFilterFromTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return ReportFilter.today;
      case 1:
        return ReportFilter.yesterday;
      case 2:
        return ReportFilter.thisWeek;
      case 3:
        return ReportFilter.thisMonth;
      default:
        return ReportFilter.today;
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertTriangle,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading reports',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: _loadReports,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String periodText = '';
    switch (_selectedFilter) {
      case ReportFilter.today:
        periodText = 'today';
        break;
      case ReportFilter.yesterday:
        periodText = 'yesterday';
        break;
      case ReportFilter.thisWeek:
        periodText = 'this week';
        break;
      case ReportFilter.thisMonth:
        periodText = 'this month';
        break;
    }

    return Center(
      child: Text(
        'No reports for $periodText',
        style: GoogleFonts.inter(
          fontSize: 15,
          color: Colors.grey[500],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildReportsList(List<Report> reports) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadReports();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToReportDetails(report),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ImageUtils.getPlaceholderImage(
                        width: 48,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  report.client.fullName,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      _getStatusBackgroundColor(report.status),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  report.status,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: _getStatusColor(report.status),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.visitType?.name ?? 'Unknown Visit Type',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (report.summary.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.fileText,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Summary',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.summary.length > 100
                              ? '${report.summary.substring(0, 100)}...'
                              : report.summary,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.clock,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visit Time',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textFaded,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${DateFormat('MMM d, yyyy').format(report.checkInTime)} • ${_calculateDuration(report.checkInTime, report.checkOutTime ?? report.checkInTime)}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
    if (reports.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    switch (_selectedFilter) {
      case ReportFilter.today:
        return reports
            .where((report) =>
                report.checkInTime.year == today.year &&
                report.checkInTime.month == today.month &&
                report.checkInTime.day == today.day)
            .toList();
      case ReportFilter.yesterday:
        return reports
            .where((report) =>
                report.checkInTime.year == yesterday.year &&
                report.checkInTime.month == yesterday.month &&
                report.checkInTime.day == yesterday.day)
            .toList();
      case ReportFilter.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return reports
            .where((report) => report.checkInTime.isAfter(startOfWeek))
            .toList();
      case ReportFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return reports
            .where((report) => report.checkInTime.isAfter(startOfMonth))
            .toList();
    }
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELED':
        return const Color(0xFFE53935);
      case 'PENDING':
        return const Color(0xFFFFA000);
      case 'CONFIRMED':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF2196F3);
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFFE8F5E9);
      case 'CANCELED':
        return const Color(0xFFFFEBEE);
      case 'PENDING':
        return const Color(0xFFFFF3E0);
      case 'CONFIRMED':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  IconData _getVisitTypeIcon(String visitType) {
    switch (visitType.toUpperCase()) {
      case 'HOME_VISIT':
        return LucideIcons.home;
      case 'APPOINTMENT':
        return LucideIcons.calendar;
      case 'WEEKLY_CHECKUP':
        return CupertinoIcons.chart_bar_alt_fill;
      case 'CHECKUP':
        return LucideIcons.checkCircle;
      case 'EMERGENCY':
        return LucideIcons.alertTriangle;
      case 'ROUTINE':
        return LucideIcons.repeat;
      default:
        return LucideIcons.fileText;
    }
  }

  Widget _buildDashboard(List<Report> reports) {
    final completedReports = reports.where((r) => r.status == 'COMPLETED');
    final pendingReports = reports.where((r) => r.status == 'PENDING').length;
    final totalCompletedReports = completedReports.length;

    // Calculate total completed hours
    final totalCompletedHours = completedReports.fold<Duration>(
      Duration.zero,
      (total, report) =>
          total +
          (report.checkOutTime?.difference(report.checkInTime) ??
              Duration.zero),
    );

    // Calculate remaining hours (for pending reports)
    final remainingHours =
        reports.where((r) => r.status == 'PENDING').fold<Duration>(
              Duration.zero,
              (total, report) =>
                  total +
                  (report.checkOutTime?.difference(report.checkInTime) ??
                      Duration.zero),
            );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  icon: LucideIcons.checkCircle,
                  title: 'Completed Hours',
                  value:
                      '${(totalCompletedHours.inHours + (totalCompletedHours.inMinutes % 60) / 60).toStringAsFixed(1)}h',
                  color: const Color(0xFF4CAF50),
                  backgroundColor: const Color(0xFFE8F5E9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDashboardCard(
                  icon: LucideIcons.clock,
                  title: 'Remaining Hours',
                  value:
                      '${(remainingHours.inHours + (remainingHours.inMinutes % 60) / 60).toStringAsFixed(1)}h',
                  color: const Color(0xFFFFA000),
                  backgroundColor: const Color(0xFFFFF3E0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  icon: LucideIcons.fileCheck,
                  title: 'Completed Reports',
                  value: totalCompletedReports.toString(),
                  color: const Color(0xFF2196F3),
                  backgroundColor: const Color(0xFFE3F2FD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDashboardCard(
                  icon: LucideIcons.alertCircle,
                  title: 'Pending Reports',
                  value: pendingReports.toString(),
                  color: const Color(0xFFE53935),
                  backgroundColor: const Color(0xFFFFEBEE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 0.5,
            color: AppColors.dividerLight,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerLight, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportSearchDelegate extends SearchDelegate<Report?> {
  final List<Report> reports;
  final Function(Report) onReportSelected;

  ReportSearchDelegate({
    required this.reports,
    required this.onReportSelected,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          color: Colors.black54,
        ),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(CupertinoIcons.clear_circled_solid, size: 20),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(CupertinoIcons.back, size: 20),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredReports = reports.where((report) {
      final clientName = report.client.fullName.toLowerCase();
      final visitType = (report.visitType?.name ?? '').toLowerCase();
      final address = report.client.address.toLowerCase();
      final searchQuery = query.toLowerCase();

      return clientName.contains(searchQuery) ||
          visitType.contains(searchQuery) ||
          address.contains(searchQuery);
    }).toList();

    if (filteredReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.search,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredReports.length,
        separatorBuilder: (context, index) => Container(
          height: 0.5,
          color: AppColors.dividerLight,
        ),
        itemBuilder: (context, index) {
          final report = filteredReports[index];
          return Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                onReportSelected(report);
                close(context, report);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        _getVisitTypeIcon(report.visitType?.name ?? ''),
                        size: 16,
                        color: _getStatusColor(report.status),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy')
                                .format(report.checkInTime),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.client.fullName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.visitType?.name ?? 'Unknown Visit Type',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELED':
        return const Color(0xFFE53935);
      case 'PENDING':
        return const Color(0xFFFFA000);
      case 'CONFIRMED':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF2196F3);
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFFE8F5E9);
      case 'CANCELED':
        return const Color(0xFFFFEBEE);
      case 'PENDING':
        return const Color(0xFFFFF3E0);
      case 'CONFIRMED':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  IconData _getVisitTypeIcon(String visitType) {
    switch (visitType.toUpperCase()) {
      case 'HOME_VISIT':
        return CupertinoIcons.home;
      case 'APPOINTMENT':
        return CupertinoIcons.calendar;
      case 'WEEKLY_CHECKUP':
        return CupertinoIcons.chart_bar_alt_fill;
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
}
