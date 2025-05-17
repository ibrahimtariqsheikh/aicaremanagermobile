// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aicaremanagermob/models/schedule.dart';
import 'package:aicaremanagermob/models/medication.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/models/visit_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:aicaremanagermob/configs/app_api_config.dart';
import 'package:aicaremanagermob/utils/image_utils.dart';
import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum MedicationStatus {
  TAKEN,
  NOT_TAKEN,
  NOT_REPORTED,
  NOT_SCHEDULED,
}

enum MedicationTime {
  MORNING,
  AFTERNOON,
  EVENING,
  BEDTIME,
  AS_NEEDED,
}

enum ReportStatus {
  COMPLETED,
  PENDING,
  CANCELLED,
}

class VisitReport {
  final String? id;
  final String clientId;
  final String agencyId;
  final String userId;
  final String? visitTypeId;
  final String? title;
  final String? condition;
  final String? summary;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime createdAt;
  final double? checkInDistance;
  final double? checkOutDistance;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? signatureImageUrl;
  final ReportStatus status;
  final DateTime? lastEditedAt;
  final String? lastEditedBy;
  final String? lastEditReason;
  final List<dynamic>? bodyMapObservations;
  final dynamic visitSnapshot;
  final List<dynamic>? medicationSnapshot;
  final List<dynamic>? alerts;
  final List<dynamic>? editHistory;
  final List<dynamic>? tasksCompleted;

  VisitReport({
    this.id,
    required this.clientId,
    required this.agencyId,
    required this.userId,
    required this.visitTypeId,
    required this.title,
    required this.condition,
    required this.summary,
    required this.checkInTime,
    required this.checkOutTime,
    required this.createdAt,
    required this.checkInDistance,
    required this.checkOutDistance,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.signatureImageUrl,
    required this.status,
    required this.lastEditedAt,
    required this.lastEditedBy,
    required this.lastEditReason,
    required this.bodyMapObservations,
    required this.visitSnapshot,
    required this.medicationSnapshot,
    required this.alerts,
    required this.editHistory,
    required this.tasksCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'agencyId': agencyId,
      'userId': userId,
      'visitTypeId': visitTypeId,
      'title': title,
      'condition': condition,
      'summary': summary,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'checkInDistance': checkInDistance,
      'checkOutDistance': checkOutDistance,
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,
      'signatureImageUrl': signatureImageUrl,
      'status': status.toString().split('.').last,
      'lastEditedAt': lastEditedAt?.toIso8601String(),
      'lastEditedBy': lastEditedBy,
      'lastEditReason': lastEditReason,
      'bodyMapObservations': bodyMapObservations,
      'visitSnapshot': visitSnapshot,
      'medicationSnapshot': medicationSnapshot,
      'alerts': alerts,
      'editHistory': editHistory,
      'tasksCompleted': tasksCompleted,
    };
  }
}

class VisitCheckinPage extends ConsumerStatefulWidget {
  final Schedule schedule;

  const VisitCheckinPage({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  ConsumerState<VisitCheckinPage> createState() => _VisitCheckinPageState();
}

class _VisitCheckinPageState extends ConsumerState<VisitCheckinPage> {
  final Map<String, bool> _completedTasks = {};
  final Map<String, String> _taskNotes = {};
  bool _isLoading = false;
  bool _showMedicationsSection = false;
  bool _hasMedicationTasks = false;
  bool _showReportForm = false;
  bool _isLoadingLocation = false;
  final ScrollController _scrollController = ScrollController();

  // Form controllers
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _checkInLocationController =
      TextEditingController();
  final TextEditingController _checkOutLocationController =
      TextEditingController();
  String _reportReason = 'Initial visit report';

  // Location and time data
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  // ignore: unused_field
  String? _checkInAddress;
  double? _checkInDistance;
  double? _checkOutDistance;

  // Theme colors
  final Color primaryColor = const Color(0xFF3D73DD);
  final Color successColor = const Color(0xFF2ECC71);
  final Color warningColor = const Color(0xFFF39C12);
  final Color errorColor = const Color(0xFFE74C3C);
  final Color surfaceColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();

    // Initialize task completion status
    if (widget.schedule.hasAssignedTasks) {
      _hasMedicationTasks = widget.schedule.assignedTasks!.any((task) =>
          task.type == TaskType.MEDICATION ||
          task.type.toString().toLowerCase().contains('medication') ||
          task.type.toString().toLowerCase().contains('med'));

      for (var task in widget.schedule.assignedTasks!) {
        _completedTasks[task.id] = false;
        _taskNotes[task.id] = task.careworkerNotes ?? '';
      }
    }

    // Initialize medication tasks
    if (widget.schedule.hasMedications) {
      for (var medication in widget.schedule.client!.medications!) {
        if (medication.morning == true) {
          final key = 'med_${medication.id}_morning';
          _completedTasks[key] = false;
          _completedTasks['${key}_showUI'] = true;
        }
        if (medication.afternoon == true) {
          final key = 'med_${medication.id}_afternoon';
          _completedTasks[key] = false;
          _completedTasks['${key}_showUI'] = true;
        }
        if (medication.evening == true) {
          final key = 'med_${medication.id}_evening';
          _completedTasks[key] = false;
          _completedTasks['${key}_showUI'] = true;
        }
        if (medication.bedtime == true) {
          final key = 'med_${medication.id}_bedtime';
          _completedTasks[key] = false;
          _completedTasks['${key}_showUI'] = true;
        }
        if (medication.asNeeded == true) {
          final key = 'med_${medication.id}_as_needed';
          _completedTasks[key] = false;
          _completedTasks['${key}_showUI'] = true;
        }
      }
    }

    // If there are medications, expand the section by default
    if (widget.schedule.hasMedications) {
      _showMedicationsSection = true;
    }

    // Initialize form fields
    _conditionController.text = widget.schedule.visitType?.description ?? '';
    _summaryController.text =
        'Visit completed on ${DateFormat('MMM d, yyyy').format(DateTime.now())}';

    // Set default location values
    _checkInLocationController.text = 'Mobile check-in location';
    _checkOutLocationController.text = 'Mobile check-out location';

    // Record check-in time when page loads
    _checkInTime = DateTime.now();

    // Try to get current location for check-in, with fallback to defaults
    try {
      _getCurrentLocation(isCheckIn: true);
    } catch (e) {
      // Location services will use defaults set above
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _conditionController.dispose();
    _summaryController.dispose();
    _checkInLocationController.dispose();
    _checkOutLocationController.dispose();
    super.dispose();
  }

  void _toggleMedicationsSection() {
    setState(() {
      _showMedicationsSection = !_showMedicationsSection;
    });
  }

  // Request location permission
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location services are disabled. Please enable the services',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: errorColor,
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permissions are denied',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: errorColor,
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: errorColor,
        ),
      );
      return false;
    }

    return true;
  }

  // Get current location and address
  Future<void> _getCurrentLocation({required bool isCheckIn}) async {
    setState(() {
      _isLoadingLocation = true;
    });

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      // Use default values instead
      setState(() {
        if (isCheckIn) {
          _checkInAddress = 'Mobile location unavailable';
          _checkInLocationController.text = 'Mobile location unavailable';
          _checkInDistance = 0.0;
        } else {
          _checkOutLocationController.text = 'Mobile location unavailable';
          _checkOutDistance = 0.0;
        }
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      setState(() {
        if (isCheckIn) {
          _checkInDistance = _calculateDistanceToClient(position);
          _getAddressFromLatLng(position, isCheckIn: true);
        } else {
          _checkOutTime = DateTime.now();
          _checkOutDistance = _calculateDistanceToClient(position);
          _getAddressFromLatLng(position, isCheckIn: false);
        }
      });
    } catch (e) {
      // Use default values on error
      setState(() {
        if (isCheckIn) {
          _checkInAddress = 'Location service timed out';
          _checkInLocationController.text = 'Location service timed out';
          _checkInDistance = 0.0;
        } else {
          _checkOutLocationController.text = 'Location service timed out';
          _checkOutDistance = 0.0;
        }
        _isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Using default location: $e',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: warningColor,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Try Again',
            textColor: Colors.white,
            onPressed: () => _refreshLocation(isCheckIn: isCheckIn),
          ),
        ),
      );
    }
  }

  // Calculate distance between current location and client's location
  double? _calculateDistanceToClient(Position position) {
    // If client address coordinates are available, calculate distance
    // For now, just return a mock distance (in kilometers)
    return 0.5; // Example: 500m from client's location
  }

  // Get address from latitude and longitude
  Future<void> _getAddressFromLatLng(Position position,
      {required bool isCheckIn}) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        final address =
            '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';

        setState(() {
          if (isCheckIn) {
            _checkInAddress = address;
            _checkInLocationController.text = address;
          } else {
            _checkOutLocationController.text = address;
          }
          _isLoadingLocation = false;
        });
      } else {
        // No placemark found
        setState(() {
          if (isCheckIn) {
            _checkInAddress = 'Address unavailable';
            _checkInLocationController.text =
                'Location: ${position.latitude}, ${position.longitude}';
          } else {
            _checkOutLocationController.text =
                'Location: ${position.latitude}, ${position.longitude}';
          }
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      // Use coordinates if geocoding fails
      setState(() {
        if (isCheckIn) {
          _checkInAddress = 'Address lookup failed';
          _checkInLocationController.text =
              'Location: ${position.latitude}, ${position.longitude}';
        } else {
          _checkOutLocationController.text =
              'Location: ${position.latitude}, ${position.longitude}';
        }
        _isLoadingLocation = false;
      });
    }
  }

  // Manual refresh of location
  Future<void> _refreshLocation({required bool isCheckIn}) async {
    await _getCurrentLocation(isCheckIn: isCheckIn);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCheckIn
              ? 'Check-in location updated'
              : 'Check-out location updated',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: successColor,
      ),
    );
  }

  void _toggleReportForm() {
    setState(() {
      _showReportForm = !_showReportForm;

      // If showing the form, record check-out time
      if (_showReportForm) {
        _checkOutTime = DateTime.now();
        // Try to get current location for check-out, with fallback to defaults
        try {
          _getCurrentLocation(isCheckIn: false);
        } catch (e) {
          // Will use default values set in constructor
        }
      }
    });

    // Scroll to top when showing the form
    if (_showReportForm) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _completeVisit() async {
    setState(() {
      _isLoading = true;
    });

    // Collect task completion data
    final tasks = Map<String, dynamic>();
    _completedTasks.forEach((id, completed) {
      // Only include actual task completion status, not UI state helpers
      if (!id.contains('_showUI')) {
        tasks[id] = {
          'completed': completed,
          'notes': _taskNotes[id] ?? '',
        };
      }
    });

    // Prepare medication logs for the medication snapshots
    final List<Map<String, dynamic>> medicationLogs = [];
    final List<Map<String, dynamic>> medicationSnapshots = [];

    if (widget.schedule.client?.medications != null) {
      for (var medication in widget.schedule.client!.medications!) {
        // Check if this medication was administered in this visit
        bool medTaken = false;
        String? medNotes;
        MedicationTime? medTime;
        MedicationStatus medStatus = MedicationStatus.NOT_REPORTED;

        // Check each possible time for this medication
        if (medication.morning == true) {
          final medicationKey = 'med_${medication.id}_morning';
          if (_completedTasks.containsKey(medicationKey) &&
              _completedTasks['${medicationKey}_showUI'] == true) {
            medTaken = _completedTasks[medicationKey] ?? false;
            medNotes = _taskNotes[medicationKey];
            medTime = MedicationTime.MORNING;
            medStatus =
                medTaken ? MedicationStatus.TAKEN : MedicationStatus.NOT_TAKEN;
          }
        }

        if (medication.afternoon == true) {
          final medicationKey = 'med_${medication.id}_afternoon';
          if (_completedTasks.containsKey(medicationKey) &&
              _completedTasks['${medicationKey}_showUI'] == true) {
            medTaken = _completedTasks[medicationKey] ?? false;
            medNotes = _taskNotes[medicationKey];
            medTime = MedicationTime.AFTERNOON;
            medStatus =
                medTaken ? MedicationStatus.TAKEN : MedicationStatus.NOT_TAKEN;
          }
        }

        if (medication.evening == true) {
          final medicationKey = 'med_${medication.id}_evening';
          if (_completedTasks.containsKey(medicationKey) &&
              _completedTasks['${medicationKey}_showUI'] == true) {
            medTaken = _completedTasks[medicationKey] ?? false;
            medNotes = _taskNotes[medicationKey];
            medTime = MedicationTime.EVENING;
            medStatus =
                medTaken ? MedicationStatus.TAKEN : MedicationStatus.NOT_TAKEN;
          }
        }

        if (medication.bedtime == true) {
          final medicationKey = 'med_${medication.id}_bedtime';
          if (_completedTasks.containsKey(medicationKey) &&
              _completedTasks['${medicationKey}_showUI'] == true) {
            medTaken = _completedTasks[medicationKey] ?? false;
            medNotes = _taskNotes[medicationKey];
            medTime = MedicationTime.BEDTIME;
            medStatus =
                medTaken ? MedicationStatus.TAKEN : MedicationStatus.NOT_TAKEN;
          }
        }

        if (medication.asNeeded == true) {
          final medicationKey = 'med_${medication.id}_as_needed';
          if (_completedTasks.containsKey(medicationKey) &&
              _completedTasks['${medicationKey}_showUI'] == true) {
            medTaken = _completedTasks[medicationKey] ?? false;
            medNotes = _taskNotes[medicationKey];
            medTime = MedicationTime.AS_NEEDED;
            medStatus =
                medTaken ? MedicationStatus.TAKEN : MedicationStatus.NOT_TAKEN;
          }
        }

        // Create medication log if medication was administered/reported
        if (medTime != null) {
          medicationLogs.add({
            'medicationId': medication.id,
            'date': DateTime.now().toIso8601String(),
            'status': medStatus.toString().split('.').last,
            'time': medTime.toString().split('.').last,
            'careworkerId': widget.schedule.userId,
            'notes': medNotes,
            'userId': widget.schedule.clientId,
          });
        }

        // Create medication snapshot according to Prisma schema
        medicationSnapshots.add({
          'medicationId': medication.id,
          'medicationDetails': medication.toJson(),
          'logs': medicationLogs
              .where((log) => log['medicationId'] == medication.id)
              .toList(),
          'administrationStatus': medStatus.toString().split('.').last,
        });
      }
    }

    // Create a report according to the Prisma schema structure
    final visitReport = VisitReport(
      clientId: widget.schedule.clientId,
      agencyId: widget.schedule.agencyId,
      userId: widget.schedule.userId,
      visitTypeId: widget.schedule.visitTypeId,
      title: widget.schedule.visitType?.name,
      condition: _conditionController.text.isNotEmpty
          ? _conditionController.text
          : 'Regular visit',
      summary: _summaryController.text.isNotEmpty
          ? _summaryController.text
          : 'Visit completed on ${DateFormat('MMM d, yyyy').format(DateTime.now())}',
      checkInTime: _checkInTime ?? DateTime.now(),
      checkOutTime: _checkOutTime,
      createdAt: DateTime.now(),
      checkInDistance: _checkInDistance ?? 0.0,
      checkOutDistance: _checkOutDistance ?? 0.0,
      checkInLocation: _checkInLocationController.text.isNotEmpty
          ? _checkInLocationController.text
          : 'Mobile check-in location',
      checkOutLocation: _checkOutLocationController.text.isNotEmpty
          ? _checkOutLocationController.text
          : 'Mobile check-out location',
      signatureImageUrl: null,
      status: ReportStatus.COMPLETED,
      // Required fields from the Prisma schema that we need to provide
      lastEditedAt: DateTime.now(),
      lastEditedBy: widget.schedule.userId,
      lastEditReason: _reportReason,
      bodyMapObservations: [],
      visitSnapshot: {
        'visitTypeName': widget.schedule.visitType?.name ?? 'Visit',
        'visitTypeDescription': widget.schedule.visitType?.description,
        'scheduleId': widget.schedule.id,
        'visitTypeId': widget.schedule.visitTypeId,
        'taskSnapshots': widget.schedule.assignedTasks
                ?.map((task) => {
                      'originalTaskId': task.id,
                      'taskType': task.type.toString().split('.').last,
                      'taskName': _formatTaskType(task.type),
                      'careworkerNotes': _taskNotes[task.id] ?? '',
                    })
                .toList() ??
            [],
      },
      medicationSnapshot: medicationSnapshots,
      alerts: [],
      editHistory: [],
      tasksCompleted: tasks.entries
          .map((entry) => {
                'taskId': entry.key.contains('med_') ? null : entry.key,
                'taskName': entry.key.contains('med_')
                    ? 'Medication Administration'
                    : _getTaskNameFromId(entry.key),
                'completed': entry.value['completed'],
                'notes': entry.value['notes'],
                'completedAt': entry.value['completed']
                    ? DateTime.now().toIso8601String()
                    : null,
                'taskIcon': entry.key.contains('med_')
                    ? 'medication'
                    : _getTaskIconName(entry.key),
                'taskType': entry.key.contains('med_')
                    ? 'MEDICATION'
                    : _getTaskTypeFromId(entry.key),
              })
          .toList(),
    );

    try {
      // Convert the VisitReport to a JSON object that we can send to the API
      final reportData = visitReport.toJson();

      // Send the report data directly to the backend using HTTP
      final response = await http.post(
        Uri.parse(AppApiConfig.getCreateReportUrl(
            widget.schedule.userId, widget.schedule.id)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(reportData),
      );

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to submit report: ${response.statusCode}');
      }
    } catch (e) {
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting report: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show success animation and message
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: successColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Visit Check-in Complete',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All tasks have been successfully recorded and submitted.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Return to Schedule',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTaskType(TaskType type) {
    final taskName = type.toString().split('.').last;
    return taskName.substring(0, 1).toUpperCase() +
        taskName.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEE, MMM d, yyyy');
    final now = DateTime.now();
    dateFormatter.format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft,
              color: CupertinoColors.systemGrey, size: 16),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text(
          'Visit Check-in',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Submitting visit data...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  _buildClientInfo(),
                  Expanded(
                    child:
                        _showReportForm ? _buildReportForm() : _buildTaskList(),
                  ),
                  _buildCompleteButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildClientInfo() {
    final client = widget.schedule.client;
    final visitType = widget.schedule.visitType;

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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      ImageUtils.getRandomPlaceholderImage(),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client?.fullName ?? 'Unknown Client',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(LucideIcons.clock,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.schedule.startTime} - ${widget.schedule.endTime}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (visitType != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.mainBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.mainBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      visitType.name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainBlue,
                      ),
                    ),
                  ),
              ],
            ),
            if (visitType?.description != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        visitType!.description!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (!widget.schedule.hasAssignedTasks && !widget.schedule.hasMedications) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.fileText,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks assigned for this visit',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tasks will appear here when assigned by the care coordinator',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Tasks', LucideIcons.checkSquare),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: (() {
            // Create a sorted list of task types
            final sortedTypes = List<TaskType>.from(TaskType.values)
              ..sort((a, b) {
                // Sort required tasks to the top
                final aIsRequired = widget.schedule.hasAssignedTasks &&
                    widget.schedule.assignedTasks!
                        .any((task) => task.type == a);
                final bIsRequired = widget.schedule.hasAssignedTasks &&
                    widget.schedule.assignedTasks!
                        .any((task) => task.type == b);

                if (aIsRequired && !bIsRequired) return -1;
                if (!aIsRequired && bIsRequired) return 1;
                return 0;
              });

            // Map the sorted types to widgets
            return sortedTypes.map((type) {
              // Check if this task type is assigned in the visit type
              final isAssigned = widget.schedule.hasAssignedTasks &&
                  widget.schedule.assignedTasks!
                      .any((task) => task.type == type);

              // Check if this task type is assigned in medications
              final isMedicationTask = type == TaskType.MEDICATION &&
                  widget.schedule.hasMedications &&
                  widget.schedule.client?.medications != null &&
                  widget.schedule.client!.medications!.isNotEmpty;

              final isRequired = isAssigned || isMedicationTask;

              // Create a temporary AssignedTask for display
              final displayTask = AssignedTask(
                id: 'temp_${type.toString()}',
                type: type,
                careworkerNotes: '',
                visitTypeId: widget.schedule.visitTypeId ?? '',
              );

              return _buildTaskGridItem(displayTask, isRequired: isRequired);
            }).toList();
          })(),
        ),
      ],
    );
  }

  Widget _buildTaskGridItem(AssignedTask task, {bool isRequired = false}) {
    final isCompleted = _completedTasks[task.id] ?? false;
    final hasNotes = _taskNotes[task.id]?.isNotEmpty ?? false;
    final showYellow = isCompleted || hasNotes;

    return GestureDetector(
      onTap: () {
        if (!isRequired) return; // Only allow interaction with required tasks

        if (task.type == TaskType.MEDICATION &&
            widget.schedule.hasMedications) {
          // Show medications in a modal
          Navigator.of(context).push(
            CupertinoSheetRoute(
              builder: (context) => Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Medications',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(LucideIcons.x),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ...widget.schedule.client!.medications!
                              .map((medication) {
                            return _buildMedicationItem(medication);
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          return;
        }

        Navigator.of(context).push(
          CupertinoSheetRoute(
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          _formatTaskType(task.type),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(LucideIcons.x),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.cardColor,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getTaskIcon(task.type),
                                      color: showYellow
                                          ? warningColor
                                          : AppColors.mainBlue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Task Status',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 1,
                                color: AppColors.dividerLight,
                                thickness: 0.5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CupertinoButton(
                                        onPressed: () {
                                          setState(() {
                                            _completedTasks[task.id] = true;
                                          });
                                          Navigator.pop(context);
                                        },
                                        color: isCompleted
                                            ? successColor
                                            : CupertinoColors.systemGrey5,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(LucideIcons.check,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Mark as Completed',
                                                style: GoogleFonts.inter(
                                                  color: isCompleted
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CupertinoButton(
                                        onPressed: () {
                                          setState(() {
                                            _completedTasks[task.id] = false;
                                          });
                                          Navigator.pop(context);
                                        },
                                        color: !isCompleted
                                            ? errorColor
                                            : Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(LucideIcons.x,
                                                size: 16, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Mark as Not Completed',
                                                style: GoogleFonts.inter(
                                                  color: !isCompleted
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Notes',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: CupertinoTextField(
                            placeholder: 'Add notes about this task...',
                            placeholderStyle: GoogleFonts.inter(
                              color: Colors.grey[500],
                            ),
                            padding: const EdgeInsets.all(16),
                            maxLines: 3,
                            controller: TextEditingController(
                                text: _taskNotes[task.id]),
                            onChanged: (value) {
                              _taskNotes[task.id] = value;
                            },
                            decoration: null,
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRequired
                ? (showYellow
                    ? warningColor.withOpacity(0.3)
                    : AppColors.dividerLight)
                : Colors.grey[200]!,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isRequired
                    ? (showYellow
                        ? warningColor.withOpacity(0.1)
                        : AppColors.mainBlue.withOpacity(0.1))
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getTaskIcon(task.type),
                  color: isRequired
                      ? (showYellow ? warningColor : AppColors.mainBlue)
                      : Colors.grey[400],
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTaskType(task.type),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isRequired ? Colors.grey[800] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),
            if (isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: showYellow
                      ? warningColor.withOpacity(0.1)
                      : primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  showYellow ? 'In Progress' : 'Required',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: showYellow ? warningColor : primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (!isRequired && isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Completed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.MEDICATION:
        return LucideIcons.pill;
      case TaskType.BODYMAP:
        return LucideIcons.user;
      case TaskType.FOOD:
        return LucideIcons.utensils;
      case TaskType.DRINKS:
        return LucideIcons.glassWater;
      case TaskType.PERSONALCARE:
        return LucideIcons.user;
      case TaskType.HYGIENE:
        return LucideIcons.droplet;
      case TaskType.TOILET_ASSISTANCE:
        return LucideIcons.home;
      case TaskType.REPOSITIONING:
        return LucideIcons.move;
      case TaskType.COMPANIONSHIP:
        return LucideIcons.users;
      case TaskType.LAUNDRY:
        return LucideIcons.shirt;
      case TaskType.GROCERIES:
        return LucideIcons.shoppingCart;
      case TaskType.HOUSEWORK:
        return LucideIcons.home;
      case TaskType.CHORES:
        return LucideIcons.checkSquare;
      case TaskType.INCIDENT_RESPONSE:
        return LucideIcons.alertTriangle;
      case TaskType.FIRE_SAFETY:
        return LucideIcons.flame;
      case TaskType.BLOOD_PRESSURE:
        return LucideIcons.heart;
      case TaskType.VITALS:
        return LucideIcons.activity;
      case TaskType.OTHER:
        return LucideIcons.checkSquare;
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Medication medication) {
    // Determine if this medication should be taken now based on time of day
    final now = DateTime.now();
    final currentHour = now.hour;

    final bool isMorning = currentHour >= 5 && currentHour < 12;
    final bool isAfternoon = currentHour >= 12 && currentHour < 17;
    final bool isEvening = currentHour >= 17 && currentHour < 21;
    final bool isBedtime = currentHour >= 21 || currentHour < 5;

    // Instead of only showing medications for the current time period,
    // we'll show all scheduled times from the backend
    final List<Map<String, dynamic>> scheduledTimes = [];

    if (medication.morning == true) {
      scheduledTimes.add({
        'time': 'Morning',
        'color': const Color(0xFFE67E22),
        'active': isMorning,
        'key': 'morning',
        'icon': LucideIcons.sunrise
      });
    }

    if (medication.afternoon == true) {
      scheduledTimes.add({
        'time': 'Afternoon',
        'color': const Color(0xFF3498DB),
        'active': isAfternoon,
        'key': 'afternoon',
        'icon': LucideIcons.sun
      });
    }

    if (medication.evening == true) {
      scheduledTimes.add({
        'time': 'Evening',
        'color': const Color(0xFF9B59B6),
        'active': isEvening,
        'key': 'evening',
        'icon': LucideIcons.sunset
      });
    }

    if (medication.bedtime == true) {
      scheduledTimes.add({
        'time': 'Bedtime',
        'color': const Color(0xFF34495E),
        'active': isBedtime,
        'key': 'bedtime',
        'icon': LucideIcons.moon
      });
    }

    if (medication.asNeeded == true) {
      scheduledTimes.add({
        'time': 'As needed',
        'color': warningColor,
        'active': true,
        'key': 'as_needed',
        'icon': LucideIcons.clock
      });
    }

    if (scheduledTimes.isEmpty) {
      scheduledTimes.add({
        'time': 'Not scheduled',
        'color': Colors.grey,
        'active': false,
        'key': 'not_scheduled',
        'icon': LucideIcons.clock
      });
    }

    return Column(
      children: scheduledTimes.map((timeData) {
        final medicationKey = 'med_${medication.id}_${timeData['key']}';
        if (!_completedTasks.containsKey(medicationKey)) {
          _completedTasks[medicationKey] = false;
        }

        // Track if we're showing administration UI
        final bool showAdminUI =
            _completedTasks.containsKey('${medicationKey}_showUI')
                ? _completedTasks['${medicationKey}_showUI']!
                : false;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: timeData['active']
                  ? timeData['color'].withOpacity(0.3)
                  : Colors.grey[200]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: timeData['active']
                            ? timeData['color'].withOpacity(0.1)
                            : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          timeData['icon'],
                          color: timeData['active']
                              ? timeData['color']
                              : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  medication.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: timeData['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  timeData['time'],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: timeData['color'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${medication.dosage} ${medication.frequency != null ? ' • ${medication.frequency}' : ''}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (medication.instructions != null &&
                              medication.instructions!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    LucideIcons.info,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      medication.instructions!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      value: showAdminUI,
                      onChanged: (value) {
                        setState(() {
                          _completedTasks['${medicationKey}_showUI'] = value;
                        });
                      },
                      activeColor: timeData['color'],
                    ),
                  ],
                ),
              ),
              if (showAdminUI) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administration Log - ${timeData['time']}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: timeData['color'],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoButton(
                              onPressed: () {
                                setState(() {
                                  _completedTasks[medicationKey] = true;
                                });
                              },
                              color: _completedTasks[medicationKey] == true
                                  ? successColor
                                  : Colors.grey[200],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    LucideIcons.check,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Taken',
                                    style: GoogleFonts.inter(
                                      color:
                                          _completedTasks[medicationKey] == true
                                              ? Colors.white
                                              : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CupertinoButton(
                              onPressed: () {
                                setState(() {
                                  _completedTasks[medicationKey] = false;
                                });
                              },
                              color: _completedTasks[medicationKey] == false
                                  ? errorColor
                                  : Colors.grey[200],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.x, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Not Taken',
                                    style: GoogleFonts.inter(
                                      color: _completedTasks[medicationKey] ==
                                              false
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Notes',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: CupertinoTextField(
                          placeholder: _completedTasks[medicationKey] == false
                              ? 'Reason medication was not taken...'
                              : 'Notes about medication administration...',
                          placeholderStyle: GoogleFonts.inter(
                            color: Colors.grey[500],
                          ),
                          padding: const EdgeInsets.all(16),
                          maxLines: 3,
                          controller: TextEditingController(
                              text: _taskNotes[medicationKey]),
                          onChanged: (value) {
                            _taskNotes[medicationKey] = value;
                          },
                          decoration: null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompleteButton() {
    // Check task completion
    final allTasksCompleted = widget.schedule.hasAssignedTasks
        ? _completedTasks.entries
            .where((entry) =>
                !entry.key.startsWith('med_') && !entry.key.contains('_showUI'))
            .every((entry) => entry.value)
        : true;

    // Check medication administration
    bool allMedicationsTaken = true;
    if (widget.schedule.hasMedications &&
        (_showMedicationsSection || _hasMedicationTasks)) {
      for (var medication in widget.schedule.client!.medications!) {
        // Check each scheduled time for this medication
        if (medication.morning == true) {
          final medicationKey = 'med_${medication.id}_morning';
          final showUI = _completedTasks['${medicationKey}_showUI'] == true;

          if (showUI &&
              (!_completedTasks.containsKey(medicationKey) ||
                  _completedTasks[medicationKey] == null)) {
            allMedicationsTaken = false;
            break;
          }
        }

        if (medication.afternoon == true) {
          final medicationKey = 'med_${medication.id}_afternoon';
          final showUI = _completedTasks['${medicationKey}_showUI'] == true;

          if (showUI &&
              (!_completedTasks.containsKey(medicationKey) ||
                  _completedTasks[medicationKey] == null)) {
            allMedicationsTaken = false;
            break;
          }
        }

        if (medication.evening == true) {
          final medicationKey = 'med_${medication.id}_evening';
          final showUI = _completedTasks['${medicationKey}_showUI'] == true;

          if (showUI &&
              (!_completedTasks.containsKey(medicationKey) ||
                  _completedTasks[medicationKey] == null)) {
            allMedicationsTaken = false;
            break;
          }
        }

        if (medication.bedtime == true) {
          final medicationKey = 'med_${medication.id}_bedtime';
          final showUI = _completedTasks['${medicationKey}_showUI'] == true;

          if (showUI &&
              (!_completedTasks.containsKey(medicationKey) ||
                  _completedTasks[medicationKey] == null)) {
            allMedicationsTaken = false;
            break;
          }
        }

        if (medication.asNeeded == true) {
          final medicationKey = 'med_${medication.id}_as_needed';
          final showUI = _completedTasks['${medicationKey}_showUI'] == true;

          if (showUI &&
              (!_completedTasks.containsKey(medicationKey) ||
                  _completedTasks[medicationKey] == null)) {
            allMedicationsTaken = false;
            break;
          }
        }
      }
    }

    final allCompleted = allTasksCompleted && allMedicationsTaken;
    final anyTaskStarted = _completedTasks.entries
        .where((entry) => !entry.key.contains('_showUI'))
        .any((entry) => entry.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.dividerLight,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (!allCompleted && anyTaskStarted)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.alertTriangle,
                      color: const Color(0xFFF39C12),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete all tasks and required medications to finish this visit',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFFF39C12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _showReportForm
                    ? _completeVisit
                    : allCompleted
                        ? () {
                            _toggleReportForm();
                          }
                        : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _showReportForm
                        ? const Color(0xFF2ECC71)
                        : allCompleted
                            ? AppColors.mainBlue
                            : AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showReportForm
                            ? LucideIcons.checkCircle
                            : LucideIcons.arrowRight,
                        color: _showReportForm || allCompleted
                            ? Colors.white
                            : Colors.black54,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showReportForm
                            ? 'Submit Visit Report'
                            : allCompleted
                                ? 'Continue to Report'
                                : 'Complete All Tasks',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _showReportForm || allCompleted
                              ? Colors.white
                              : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showReportForm)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showReportForm = false;
                  });
                },
                child: Text(
                  'Go Back to Tasks',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportForm() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Visit Report', CupertinoIcons.doc_text),
        const SizedBox(height: 16),

        // Visit time information
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visit Time Information',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.time,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Check-in:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _checkInTime != null
                          ? DateFormat('MMM d, yyyy - h:mm a')
                              .format(_checkInTime!)
                          : 'Not recorded',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.time,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Check-out:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _checkOutTime != null
                          ? DateFormat('MMM d, yyyy - h:mm a')
                              .format(_checkOutTime!)
                          : 'Not recorded',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.clock,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Duration:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _checkInTime != null && _checkOutTime != null
                          ? _formatDuration(
                              _checkOutTime!.difference(_checkInTime!))
                          : 'Not calculated',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Condition field
        Text(
          'Client Condition',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: TextField(
            controller: _conditionController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Describe client\'s condition',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey[800],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Summary field
        Text(
          'Visit Summary',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: TextField(
            controller: _summaryController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Provide a summary of the visit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey[800],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Check-in Location field
        Row(
          children: [
            Expanded(
              child: Text(
                'Check-in Location',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            IconButton(
              onPressed: () => _refreshLocation(isCheckIn: true),
              icon: Icon(
                CupertinoIcons.refresh,
                color: primaryColor,
                size: 16,
              ),
              tooltip: 'Refresh check-in location',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              TextField(
                controller: _checkInLocationController,
                decoration: InputDecoration(
                  hintText: 'Enter check-in location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    CupertinoIcons.location_solid,
                    color: Colors.grey[500],
                    size: 16,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
              if (_isLoadingLocation)
                Positioned(
                  right: 16,
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_checkInDistance != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.arrow_up_right_diamond,
                  size: 16,
                  color: _checkInDistance! < 1.0 ? successColor : warningColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Distance from client: ${(_checkInDistance! * 1000).toStringAsFixed(0)} meters',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color:
                        _checkInDistance! < 1.0 ? successColor : warningColor,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Check-out Location field
        Row(
          children: [
            Expanded(
              child: Text(
                'Check-out Location',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            IconButton(
              onPressed: () => _refreshLocation(isCheckIn: false),
              icon: Icon(
                CupertinoIcons.refresh,
                color: primaryColor,
                size: 16,
              ),
              tooltip: 'Refresh check-out location',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              TextField(
                controller: _checkOutLocationController,
                decoration: InputDecoration(
                  hintText: 'Enter check-out location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    CupertinoIcons.location_solid,
                    color: Colors.grey[500],
                    size: 16,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
              if (_isLoadingLocation)
                Positioned(
                  right: 16,
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_checkOutDistance != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.arrow_up_right_diamond,
                  size: 16,
                  color: _checkOutDistance! < 1.0 ? successColor : warningColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Distance from client: ${(_checkOutDistance! * 1000).toStringAsFixed(0)} meters',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color:
                        _checkOutDistance! < 1.0 ? successColor : warningColor,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Task Types section
        Text(
          'Task Types',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...TaskType.values.map((type) {
                // Check if this task type is assigned in the visit type
                final isAssigned = widget.schedule.hasAssignedTasks &&
                    widget.schedule.assignedTasks!
                        .any((task) => task.type == type);

                // Check if this task type is assigned in medications
                final isMedicationTask = type == TaskType.MEDICATION &&
                    widget.schedule.hasMedications &&
                    widget.schedule.client?.medications != null &&
                    widget.schedule.client!.medications!.isNotEmpty;

                final isRequired = isAssigned || isMedicationTask;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        _getTaskIcon(type),
                        size: 16,
                        color: isRequired ? primaryColor : Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatTaskType(type),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isRequired
                                ? Colors.grey[800]
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Required',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Report Reason field
        Text(
          'Report Notes/Reason',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _reportReason,
              isExpanded: true,
              icon: Icon(
                CupertinoIcons.chevron_down,
                color: Colors.grey[700],
                size: 16,
              ),
              items: [
                DropdownMenuItem(
                  value: 'Initial visit report',
                  child: Text('Initial visit report'),
                ),
                DropdownMenuItem(
                  value: 'Follow-up visit',
                  child: Text('Follow-up visit'),
                ),
                DropdownMenuItem(
                  value: 'Emergency visit',
                  child: Text('Emergency visit'),
                ),
                DropdownMenuItem(
                  value: 'Routine visit',
                  child: Text('Routine visit'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _reportReason = value!;
                });
              },
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey[800],
              ),
              dropdownColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitHours = twoDigits(duration.inHours);
    return '${twoDigitHours}h ${twoDigitMinutes}m';
  }

  // Helper function to get task name from ID
  String _getTaskNameFromId(String taskId) {
    // First try to find the task in the assigned tasks
    if (widget.schedule.hasAssignedTasks) {
      for (var task in widget.schedule.assignedTasks!) {
        if (task.id == taskId) {
          return _formatTaskType(task.type);
        }
      }
    }

    // If not found, use a generic name
    return 'Task';
  }

  // Helper function to get task type from ID
  String _getTaskTypeFromId(String taskId) {
    // First try to find the task in the assigned tasks
    if (widget.schedule.hasAssignedTasks) {
      for (var task in widget.schedule.assignedTasks!) {
        if (task.id == taskId) {
          return task.type.toString().split('.').last;
        }
      }
    }

    // If not found, use OTHER as default
    return 'OTHER';
  }

  // Helper function to get task icon name from task ID
  String _getTaskIconName(String taskId) {
    // First try to find the task in the assigned tasks
    if (widget.schedule.hasAssignedTasks) {
      for (var task in widget.schedule.assignedTasks!) {
        if (task.id == taskId) {
          final String typeName = task.type.toString().toLowerCase();

          if (typeName.contains('medication') || typeName.contains('med')) {
            return 'medication';
          } else if (typeName.contains('bath') ||
              typeName.contains('hygiene')) {
            return 'hygiene';
          } else if (typeName.contains('meal') || typeName.contains('food')) {
            return 'food';
          } else if (typeName.contains('walk') ||
              typeName.contains('exercise')) {
            return 'exercise';
          } else if (typeName.contains('clean')) {
            return 'cleaning';
          } else {
            return 'task';
          }
        }
      }
    }

    // If not found, use a default icon
    return 'task';
  }
}
