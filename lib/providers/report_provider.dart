import 'package:aicaremanagermob/models/report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aicaremanagermob/configs/app_api_config.dart';
import 'package:equatable/equatable.dart';

part 'report_provider.g.dart';

// Report State
class ReportState extends Equatable {
  final List<Report> reports;
  final bool isLoading;
  final String? error;

  const ReportState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [reports, isLoading, error];

  ReportState copyWith({
    List<Report>? reports,
    bool? isLoading,
    String? error,
  }) {
    return ReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

@Riverpod(keepAlive: true)
class ReportNotifier extends _$ReportNotifier {
  @override
  ReportState build() {
    return const ReportState();
  }

  Future<void> createReport(
      String userId, String scheduleId, Report report) async {
    print('Creating report for user: $userId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await http.post(
        Uri.parse(AppApiConfig.getCreateReportUrl(userId, scheduleId)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(report.toJson()),
      );

      if (response.statusCode == 200) {
        print('Report created successfully');
      } else {
        print('Failed to create report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating report: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadReports(String userId) async {
    print('Loading reports for user: $userId');

    // Only update loading state if we're not already loading
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await http.get(
        Uri.parse(AppApiConfig.getCareworkerReportUrl(userId)),
      );

      if (response.statusCode == 200) {
        final reports = json.decode(response.body) as List;
        final parsedReports =
            reports.map((report) => Report.fromJson(report)).toList();

        print('REPORT RESPONSE: $parsedReports');
        state = state.copyWith(
          reports: parsedReports,
          isLoading: false,
          error: null,
        );
      } else {
        final errorMessage = 'Failed to load reports: ${response.statusCode}';
        print(errorMessage);
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error loading reports: $e');
      final errorMessage = e.toString();
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      throw Exception(errorMessage);
    }
  }

  void updateReport(Report report) {
    print('Updating report: ${report.id}');
    state = state.copyWith(
      reports:
          state.reports.map((r) => r.id == report.id ? report : r).toList(),
    );
  }

  // Filter reports by status
  List<Report> getReportsByStatus(String status) {
    return state.reports.where((report) => report.status == status).toList();
  }

  // Get a specific report by ID
  Report? getReportById(String reportId) {
    try {
      return state.reports.firstWhere((report) => report.id == reportId);
    } catch (e) {
      return null;
    }
  }
}
