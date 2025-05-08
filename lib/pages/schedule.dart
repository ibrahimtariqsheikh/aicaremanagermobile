import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:equatable/equatable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aicaremanagermob/models/schedule.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aicaremanagermob/configs/app_api_config.dart';
import 'package:aicaremanagermob/pages/appointment_details_page.dart';
import 'dart:async';

// Schedule State
class ScheduleState extends Equatable {
  final List<Schedule> schedules;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final List<Schedule> filteredSchedules;
  final bool isSearching;

  const ScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filteredSchedules = const [],
    this.isSearching = false,
  });

  ScheduleState copyWith({
    List<Schedule>? schedules,
    bool? isLoading,
    String? error,
    String? searchQuery,
    List<Schedule>? filteredSchedules,
    bool? isSearching,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredSchedules: filteredSchedules ?? this.filteredSchedules,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        schedules,
        isLoading,
        error,
        searchQuery,
        filteredSchedules,
        isSearching,
      ];
}

// Schedule Notifier
class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final AuthState authState;
  Timer? _debounce;

  ScheduleNotifier(this.authState) : super(const ScheduleState()) {
    print('ScheduleNotifier initialized');
    loadInitialSchedules();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void loadInitialSchedules() {
    print('Loading initial schedules...');
    state = state.copyWith(isLoading: true);
    loadSchedules(authState.user.id);
  }

  // Add a method to refresh schedules
  void refreshSchedules() {
    print('Refreshing schedules...');
    loadInitialSchedules();
  }

  void addSchedule(Schedule schedule) {
    print('Adding new schedule: ${schedule.id}');
    // Here you would typically make an API call to add the schedule
    state = state.copyWith(
      schedules: [...state.schedules, schedule],
    );
    print('State now has ${state.schedules.length} schedules');
  }

  void updateSchedule(Schedule schedule) {
    print('Updating schedule: ${schedule.id}');
    // Here you would typically make an API call to update the schedule
    state = state.copyWith(
      schedules: state.schedules
          .map((s) => s.id == schedule.id ? schedule : s)
          .toList(),
    );
  }

  void deleteSchedule(String id) {
    print('Deleting schedule: $id');
    // Here you would typically make an API call to delete the schedule
    state = state.copyWith(
      schedules: state.schedules.where((s) => s.id != id).toList(),
    );
  }

  void updateScheduleStatus(String id, String status) {
    print('Updating schedule status: $id to $status');
    state = state.copyWith(
      schedules: state.schedules.map((schedule) {
        if (schedule.id == id) {
          return schedule.copyWith(status: status);
        }
        return schedule;
      }).toList(),
    );
  }

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        state = state.copyWith(
          searchQuery: '',
          filteredSchedules: state.schedules,
          isSearching: false,
        );
      } else {
        state = state.copyWith(isSearching: true);

        final filtered = state.schedules.where((schedule) {
          final clientName = schedule.client?.fullName.toLowerCase() ?? '';
          final notes = schedule.notes?.toLowerCase() ?? '';
          final type = schedule.type.toString().toLowerCase();
          final status = schedule.status.toLowerCase();
          final address = schedule.client?.address?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return clientName.contains(searchLower) ||
              notes.contains(searchLower) ||
              type.contains(searchLower) ||
              status.contains(searchLower) ||
              address.contains(searchLower);
        }).toList();

        state = state.copyWith(
          searchQuery: query,
          filteredSchedules: filtered,
          isSearching: false,
        );
      }
    });
  }

  Future<void> loadSchedules(String userId) async {
    print('Loading schedules for user: $userId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await http.get(
        Uri.parse(AppApiConfig.getScheduleUrl(userId)),
      );

      print('Schedule API Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> schedulesData = json.decode(response.body);
        print('Parsed schedules data: $schedulesData');

        final List<Schedule> schedules = schedulesData.map((schedule) {
          print('Converting schedule: $schedule');
          return Schedule.fromJson(schedule);
        }).toList();

        print('Converted ${schedules.length} schedules');
        state = state.copyWith(
          schedules: schedules,
          filteredSchedules: schedules,
          isLoading: false,
        );
        print('Updated state with ${state.schedules.length} schedules');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load schedules: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error loading schedules: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Providers
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final scheduleNotifierProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  final authState = ref.watch(authProvider);
  return ScheduleNotifier(authState);
});

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load schedules when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      ref
          .read(scheduleNotifierProvider.notifier)
          .loadSchedules(authState.user.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final currentDate = DateTime.now();
    final scheduleState = ref.watch(scheduleNotifierProvider);
    final authState = ref.watch(authProvider);

    // Refresh schedules when auth state changes
    ref.listen(authProvider, (previous, next) {
      if (previous?.user.id != next.user.id) {
        ref.read(scheduleNotifierProvider.notifier).loadSchedules(next.user.id);
      }
    });

    return Scaffold(
      backgroundColor: CupertinoColors.systemBackground,
      appBar: AppBar(
        backgroundColor: CupertinoColors.systemBackground,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search schedules...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (value) {
                  ref
                      .read(scheduleNotifierProvider.notifier)
                      .setSearchQuery(value);
                },
              )
            : Text(
                'Upcoming Schedules',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(CupertinoIcons.xmark,
                  size: 20, color: Colors.black54),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  ref
                      .read(scheduleNotifierProvider.notifier)
                      .setSearchQuery('');
                });
              },
            )
          else
            IconButton(
              icon: const Icon(CupertinoIcons.search,
                  size: 20, color: Colors.black54),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _searchFocusNode.requestFocus();
                });
              },
            ),
        ],
      ),
      body: scheduleState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!_isSearching) ...[
                  _buildMonthHeader(context, selectedDate),
                  _buildWeekView(context, ref, currentDate, selectedDate),
                ],
                if (_isSearching && scheduleState.isSearching)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                Expanded(
                  child: _buildScheduleList(
                    context,
                    ref,
                    selectedDate,
                    scheduleState,
                    isSearching: _isSearching,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthHeader(BuildContext context, DateTime selectedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                DateFormat('MMM yyyy').format(selectedDate),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            'Today',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, WidgetRef ref,
      DateTime currentDate, DateTime selectedDate) {
    final startOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final isToday = DateUtils.isSameDay(date, currentDate);
              final isSelected = DateUtils.isSameDay(date, selectedDate);
              final isWeekend = index >= 5;

              return GestureDetector(
                onTap: () {
                  ref.read(selectedDateProvider.notifier).state = date;
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CupertinoColors.systemBlue
                        : isToday
                            ? const Color(0xFFF5F5F5)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? Colors.black54
                                  : (isWeekend
                                      ? Colors.black45
                                      : Colors.black54),
                          fontWeight: isToday || isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      Text(
                        date.day.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? Colors.black
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const Divider(height: 1, color: Colors.black12, thickness: 0.3),
      ],
    );
  }

  Widget _buildScheduleList(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    ScheduleState scheduleState, {
    bool isSearching = false,
  }) {
    final schedules = isSearching
        ? scheduleState.filteredSchedules
        : scheduleState.schedules
            .where(
                (schedule) => DateUtils.isSameDay(schedule.date, selectedDate))
            .toList();

    if (isSearching && schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.search,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No schedules found',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (scheduleState.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try different keywords',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.calendar,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No schedules for this date',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _buildScheduleItem(context, ref, schedule);
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date, bool isToday) {
    String dateText = DateFormat('MMM d').format(date);
    String dayText = DateFormat('EEEE').format(date);

    if (isToday) {
      dateText += ' • Today';
    } else if (DateUtils.isSameDay(
        date, DateTime.now().add(const Duration(days: 1)))) {
      dateText += ' • Tomorrow';
    }

    dateText += ' • $dayText';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        dateText,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
      BuildContext context, WidgetRef ref, Schedule schedule) {
    final status = schedule.status;
    print('Status: $status');
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AppointmentDetailsPage(schedule: schedule),
          ),
        );
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
                    color: _getStatusBackgroundColor(schedule.status),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(schedule.status),
                    size: 16,
                    color: _getStatusColor(schedule.status),
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
                            _formatTime(schedule.startTime),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(' - ',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              )),
                          Text(
                            _formatTime(schedule.endTime),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        schedule.client?.fullName ?? 'Unnamed Client',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (schedule.client?.address != null &&
                          schedule.client!.address!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.location,
                                size: 14, color: Colors.black54),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                schedule.client!.address!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(schedule.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        schedule.status,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _getStatusColor(schedule.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12, thickness: 0.3),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF2196F3); // Material Blue
      case 'PENDING':
        return const Color(0xFFFF9800); // Material Orange
      case 'COMPLETED':
        return const Color(0xFF4CAF50); // Material Green
      case 'CANCELED':
        return const Color(0xFFE53935); // Material Red
      default:
        return const Color(0xFF757575); // Material Grey
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFFE3F2FD); // Light Blue
      case 'PENDING':
        return const Color(0xFFFFF3E0); // Light Orange
      case 'COMPLETED':
        return const Color(0xFFE8F5E9); // Light Green
      case 'CANCELED':
        return const Color(0xFFFFEBEE); // Light Red
      default:
        return const Color(0xFFEEEEEE); // Light Grey
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return CupertinoIcons.checkmark_circle_fill;
      case 'PENDING':
        return CupertinoIcons.clock_fill;
      case 'COMPLETED':
        return CupertinoIcons.checkmark_circle_fill;
      case 'CANCELED':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.circle_fill;
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      print('Error formatting time: $e');
      return time;
    }
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedDate = ref.read(selectedDateProvider);
    String? startTime;
    String? endTime;
    String type = 'HOME_VISIT';
    String status = 'PENDING';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add New Schedule', style: GoogleFonts.inter()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Client ID',
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF007AFF), width: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: 'Visit Type',
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF007AFF), width: 0.5),
                    ),
                  ),
                  items: [
                    'HOME_VISIT',
                    'APPOINTMENT',
                    'WEEKLY_CHECKUP',
                    'CHECKUP',
                    'EMERGENCY',
                    'ROUTINE',
                    'OTHER'
                  ].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => type = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => startTime =
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                          }
                        },
                        child: Text(startTime ?? 'Start Time',
                            style: GoogleFonts.inter()),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => endTime =
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                          }
                        },
                        child: Text(endTime ?? 'End Time',
                            style: GoogleFonts.inter()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF007AFF), width: 0.5),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter()),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    startTime != null &&
                    endTime != null) {
                  final newSchedule = Schedule(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    clientId: titleController.text,
                    agencyId: authState.user.agencyId ?? '',
                    userId: authState.user.id,
                    date: selectedDate,
                    startTime: startTime!,
                    endTime: endTime!,
                    status: status,
                    type: ScheduleType.values.firstWhere(
                      (e) => e.toApiString() == type,
                      orElse: () => ScheduleType.homeVisit,
                    ),
                    notes: descriptionController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  ref
                      .read(scheduleNotifierProvider.notifier)
                      .addSchedule(newSchedule);
                  Navigator.pop(context);
                }
              },
              child: Text('Add Schedule', style: GoogleFonts.inter()),
            ),
          ],
        ),
      ),
    );
  }
}
