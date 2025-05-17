import 'package:aicaremanagermob/configs/app_theme.dart';
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
import 'package:lucide_icons/lucide_icons.dart';

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
    loadInitialSchedules();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void loadInitialSchedules() {
    state = state.copyWith(isLoading: true);
    loadSchedules(authState.user.id);
  }

  // Add a method to refresh schedules
  void refreshSchedules() {
    loadInitialSchedules();
  }

  void addSchedule(Schedule schedule) {
    // Here you would typically make an API call to add the schedule
    state = state.copyWith(
      schedules: [...state.schedules, schedule],
    );
  }

  void updateSchedule(Schedule schedule) {
    // Here you would typically make an API call to update the schedule
    state = state.copyWith(
      schedules: state.schedules
          .map((s) => s.id == schedule.id ? schedule : s)
          .toList(),
    );
  }

  void deleteSchedule(String id) {
    // Here you would typically make an API call to delete the schedule
    state = state.copyWith(
      schedules: state.schedules.where((s) => s.id != id).toList(),
    );
  }

  void updateScheduleStatus(String id, String status) {
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await http.get(
        Uri.parse(AppApiConfig.getScheduleUrl(userId)),
      );

      if (response.statusCode == 200) {
        final List<dynamic> schedulesData = json.decode(response.body);

        final List<Schedule> schedules = schedulesData.map((schedule) {
          return Schedule.fromJson(schedule);
        }).toList();

        state = state.copyWith(
          schedules: schedules,
          filteredSchedules: schedules,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load schedules: ${response.statusCode}',
        );
      }
    } catch (e) {
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
    ref.watch(authProvider);

    // Refresh schedules when auth state changes
    ref.listen(authProvider, (previous, next) {
      if (previous?.user.id != next.user.id) {
        ref.read(scheduleNotifierProvider.notifier).loadSchedules(next.user.id);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: _isSearching
            ? Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search schedules...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    prefixIcon: const Icon(LucideIcons.search,
                        size: 16, color: Colors.black54),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (value) {
                    ref
                        .read(scheduleNotifierProvider.notifier)
                        .setSearchQuery(value);
                  },
                ),
              )
            : Text(
                'Schedules',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(LucideIcons.x, size: 16, color: Colors.black54),
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
              icon: const Icon(LucideIcons.search,
                  size: 16, color: Colors.black54),
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
              mainAxisSize: MainAxisSize.min,
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
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(selectedDate),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              final today = DateTime.now();
              ref.read(selectedDateProvider.notifier).state = today;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mainBlue.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 16,
                    color: AppColors.mainBlue.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Today',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mainBlue.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, WidgetRef ref,
      DateTime currentDate, DateTime selectedDate) {
    final startDate = currentDate.subtract(const Duration(days: 5));

    return Container(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          SizedBox(
            height: 85,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: List.generate(11, (index) {
                    final date = startDate.add(Duration(days: index));
                    final isToday = DateUtils.isSameDay(date, currentDate);
                    final isSelected = DateUtils.isSameDay(date, selectedDate);
                    final isWeekend = date.weekday == 6 || date.weekday == 7;

                    return GestureDetector(
                      onTap: () {
                        ref.read(selectedDateProvider.notifier).state = date;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.mainBlue.withValues(alpha: 0.9)
                              : isToday
                                  ? const Color(0xFFF5F5F5)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.mainBlue.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            const SizedBox(height: 4),
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
            ),
          ),
          const Divider(height: 1, color: Colors.black12, thickness: 0.3),
        ],
      ),
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

    // Sort schedules by start time
    schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Find the next upcoming appointment
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final nextUpcomingIndex = schedules.indexWhere((schedule) =>
        schedule.status != 'COMPLETED' &&
        schedule.status != 'CANCELED' &&
        schedule.startTime.compareTo(currentTime) >= 0);

    if (isSearching && schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.search,
                size: 24,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No schedules found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            if (scheduleState.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Try different keywords',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.calendar,
                size: 24,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No schedules for this date',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select a different date or create a new schedule',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final isNextUpcoming = index == nextUpcomingIndex;
        return _buildScheduleItem(context, ref, schedule,
            isNextUpcoming: isNextUpcoming);
      },
    );
  }

  Widget _buildScheduleItem(
      BuildContext context, WidgetRef ref, Schedule schedule,
      {bool isNextUpcoming = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AppointmentDetailsPage(schedule: schedule),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isNextUpcoming ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: isNextUpcoming
              ? Border.all(
                  color: AppColors.mainBlue.withValues(alpha: 0.5), width: 1)
              : Border.all(color: AppColors.dividerLight, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(schedule.status),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusBackgroundColor(schedule.status)
                          .withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(schedule.status),
                  size: 18,
                  color: _getStatusColor(schedule.status),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        if (isNextUpcoming) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.mainBlue,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mainBlue.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.clock,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Next Upcoming',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      schedule.client?.fullName ?? 'Unnamed Client',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (schedule.client?.address != null &&
                        schedule.client!.address!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(schedule.status),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusBackgroundColor(schedule.status)
                          .withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
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
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF2196F3); // Material Blue
      case 'PENDING':
        return const Color(0xFFE65100); // Deep Orange
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
        return const Color(0xFFFFECDB); // Light Orange
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
        return LucideIcons.checkCircle2;
      case 'PENDING':
        return LucideIcons.clock;
      case 'COMPLETED':
        return LucideIcons.checkCircle2;
      case 'CANCELED':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.circle;
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
      return time;
    }
  }
}
