import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'reports.dart';

class ReportDetailsPage extends StatelessWidget {
  final Report report;

  const ReportDetailsPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Visit Report',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.share, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: Colors.black12, thickness: 0.3),
            _buildDetails(),
            if (report.notes != null) _buildNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(report.status),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getVisitTypeIcon(report.visitType),
                  size: 20,
                  color: _getStatusColor(report.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.clientName,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(report.date),
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(report.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatVisitType(report.visitType),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _getStatusColor(report.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visit Details',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Duration', report.duration),
          if (report.address != null)
            _buildDetailRow('Location', report.address!),
          _buildDetailRow('Status', report.status),
          _buildDetailRow('Visit Type', _formatVisitType(report.visitType)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              report.notes!,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
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
