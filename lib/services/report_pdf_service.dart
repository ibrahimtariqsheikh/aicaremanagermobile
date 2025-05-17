import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aicaremanagermob/models/report.dart';
import 'package:intl/intl.dart';

class ReportPdfService {
  static Future<void> generateAndSharePdf(Report report) async {
    try {
      print('Creating PDF document...');
      final pdf = pw.Document();

      // Add pages to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader(report),
            _buildClientInfo(report),
            _buildVisitDetails(report),
            _buildVisitSnapshot(report),
            if (report.medicationSnapshot.isNotEmpty) _buildMedications(report),
            if (report.tasksCompleted?.isNotEmpty ?? false) _buildTasks(report),
          ],
        ),
      );

      print('Saving PDF to temporary file...');
      // Save the PDF to a temporary file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/visit_report_${report.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      print('Sharing PDF file...');
      // Share the PDF file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Visit Report for ${report.client.fullName}',
      );
      print('PDF sharing completed successfully');
    } catch (e, stackTrace) {
      print('Error in generateAndSharePdf: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static pw.Widget _buildHeader(Report report) {
    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Visit Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Date: ${DateFormat('MMMM d, yyyy').format(report.checkInTime)}',
            style: const pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildClientInfo(Report report) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Client Information',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Name: ${report.client.fullName}'),
          pw.Text('Visit Type: ${report.visitType?.name ?? "Unknown"}'),
          pw.Text('Status: ${report.status}'),
        ],
      ),
    );
  }

  static pw.Widget _buildVisitDetails(Report report) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Visit Details',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
              'Check-in Time: ${DateFormat('MMM d, yyyy h:mm a').format(report.checkInTime)}'),
          if (report.checkOutTime != null)
            pw.Text(
                'Check-out Time: ${DateFormat('MMM d, yyyy h:mm a').format(report.checkOutTime!)}'),
          if (report.checkInLocation != null)
            pw.Text('Location: ${report.checkInLocation}'),
          pw.Text(
              'Duration: ${report.checkInTime.difference(report.checkOutTime ?? DateTime.now()).inMinutes} minutes'),
        ],
      ),
    );
  }

  static pw.Widget _buildVisitSnapshot(Report report) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Visit Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(report.summary),
        ],
      ),
    );
  }

  static pw.Widget _buildMedications(Report report) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Medications Administered',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Medication', 'Dosage', 'Time', 'Notes'],
            data: report.medicationSnapshot
                .map((med) => [
                      med.medication.name,
                      med.medication.dosage,
                      DateFormat('h:mm a').format(med.medication.createdAt),
                      med.medication.instructions ?? '',
                    ])
                .toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTasks(Report report) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Completed Tasks',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Task', 'Status', 'Notes'],
            data: report.tasksCompleted!
                .map((task) => [
                      task.taskName,
                      task.completed ? 'Completed' : 'Not Completed',
                      task.notes ?? '',
                    ])
                .toList(),
          ),
        ],
      ),
    );
  }
}
