import 'package:aicaremanagermob/models/schedule.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aicaremanagermob/configs/app_api_config.dart';
import 'package:equatable/equatable.dart';

part 'schedule_provider.g.dart';

// Schedule State
class ScheduleState extends Equatable {
  final List<Schedule> schedules;
  final bool isLoading;
  final String? error;

  const ScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [schedules, isLoading, error];

  ScheduleState copyWith({
    List<Schedule>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

@riverpod
class ScheduleNotifier extends _$ScheduleNotifier {
  @override
  ScheduleState build() {
    return const ScheduleState();
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

  void addSchedule(Schedule schedule) {
    print('Adding new schedule: ${schedule.id}');
    state = state.copyWith(
      schedules: [...state.schedules, schedule],
    );
    print('State now has ${state.schedules.length} schedules');
  }

  void updateSchedule(Schedule schedule) {
    print('Updating schedule: ${schedule.id}');
    state = state.copyWith(
      schedules: state.schedules
          .map((s) => s.id == schedule.id ? schedule : s)
          .toList(),
    );
  }

  void deleteSchedule(String id) {
    print('Deleting schedule: $id');
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
}
