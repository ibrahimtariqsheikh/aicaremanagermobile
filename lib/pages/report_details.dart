import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:aicaremanagermob/models/report.dart';
import 'package:aicaremanagermob/services/report_pdf_service.dart';
import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReportDetailsPage extends StatefulWidget {
  final Report report;

  const ReportDetailsPage({super.key, required this.report});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft,
              color: CupertinoColors.systemGrey, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        middle: Text(
          'Visit Report',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        trailing: _isSharing
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(LucideIcons.share2,
                    color: CupertinoColors.systemGrey, size: 16),
                onPressed: () async {
                  setState(() {
                    _isSharing = true;
                  });

                  try {
                    await ReportPdfService.generateAndSharePdf(widget.report);
                  } catch (e, stackTrace) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error generating PDF: ${e.toString()}',
                            style: GoogleFonts.inter(),
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isSharing = false;
                      });
                    }
                  }
                },
              ),
      ),
      body: SafeArea(
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportHeader(),
                _buildOverviewSection(),
                _buildVisitDetailsSection(),
                if (widget.report.summary.isNotEmpty) _buildNotesSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(DateTime start, DateTime? end) {
    final endTime = end ?? DateTime.now();
    final difference = endTime.difference(start);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '$hours hours ${minutes > 0 ? '$minutes minutes' : ''}';
    }
    return '$minutes minutes';
  }

  Widget _buildReportHeader() {
    final formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(widget.report.checkInTime);
    final isToday =
        DateUtils.isSameDay(widget.report.checkInTime, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
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
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(widget.report.status),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getVisitTypeIcon(widget.report.visitType?.name ?? ''),
                    size: 20,
                    color: _getStatusColor(widget.report.status),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.report.client.fullName,
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
                    widget.report.visitType?.name ?? 'Unknown',
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
                        'Duration',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textFaded,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _formatDuration(widget.report.checkInTime,
                            widget.report.checkOutTime),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Overview'),
        _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  LucideIcons.user,
                  'Client Name',
                  value: widget.report.client.fullName,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  LucideIcons.calendar,
                  'Date',
                  value: DateFormat('MMMM d, yyyy')
                      .format(widget.report.checkInTime),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  LucideIcons.clock,
                  'Duration',
                  value: _formatDuration(
                      widget.report.checkInTime, widget.report.checkOutTime),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Visit Details'),
        _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  LucideIcons.mapPin,
                  'Location',
                  value: widget.report.checkInLocation ?? 'Not provided',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  LucideIcons.tag,
                  'Status',
                  value: widget.report.status,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  LucideIcons.clipboardList,
                  'Visit Type',
                  value: widget.report.visitType?.name ?? 'Unknown',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Notes'),
        _buildCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.mainBlue.withOpacity(0.1),
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
                      'Visit Notes',
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
                    widget.report.summary,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
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

  IconData _getVisitTypeIcon(String visitType) {
    switch (visitType.toUpperCase()) {
      case 'HOME_VISIT':
        return LucideIcons.home;
      case 'APPOINTMENT':
        return LucideIcons.calendar;
      case 'WEEKLY_CHECKUP':
        return LucideIcons.barChart2;
      case 'CHECKUP':
        return LucideIcons.clipboardCheck;
      case 'EMERGENCY':
        return LucideIcons.alertTriangle;
      case 'ROUTINE':
        return LucideIcons.repeat;
      default:
        return LucideIcons.fileText;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF2196F3);
      case 'CANCELED':
        return const Color(0xFFE53935);
      case 'PENDING':
        return const Color(0xFF2196F3);
      case 'CONFIRMED':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF2196F3);
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFFE3F2FD);
      case 'CANCELED':
        return const Color(0xFFFFEBEE);
      case 'PENDING':
        return const Color(0xFFE3F2FD);
      case 'CONFIRMED':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFE3F2FD);
    }
  }
}
