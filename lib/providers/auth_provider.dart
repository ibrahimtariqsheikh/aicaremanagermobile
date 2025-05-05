import 'package:aicaremanagermob/models/schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
//  import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aicaremanagermob/configs/app_api_config.dart';
import '../models/user.dart';
import 'package:equatable/equatable.dart';

part 'auth_provider.g.dart';

// Default user for initial state
final _defaultUser = User(
  id: 'default',
  cognitoId: 'default',
  email: 'default@example.com',
  fullName: 'Guest User',
  role: Role.client,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

class AuthState extends Equatable {
  final bool isLoading;
  final String? error;
  final User user;
  final List<Schedule> schedules;

  const AuthState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.schedules,
  });

  @override
  List<Object?> get props => [isLoading, error, user];

  @override
  bool get stringify => true;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    List<Schedule>? schedules,
  }) {
    print('AuthState - Creating new state with:');
    print('  isLoading: ${isLoading ?? this.isLoading}');
    print('  error: ${error ?? this.error}');
    print('  user: ${user ?? this.user}');
    print('  schedules: ${schedules ?? this.schedules}');
    
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      schedules: schedules ?? this.schedules,
    );
  }

  factory AuthState.initial() {
    print('AuthState - Creating initial state with default user');
    return AuthState(
      isLoading: false,
      error: null,
      user: _defaultUser,
      schedules: [],
    );
  }
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<String> signIn() async {
    try {
      print('Auth - Starting sign in...');
      state = state.copyWith(isLoading: true);
      
      final response = await http.get(
        Uri.parse(AppApiConfig.getUserUrl('cm9n1ok5x00038ohc8boavle3')),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final userData = responseData['data'];
        final user = User.fromJson(userData);
      
        state = state.copyWith(
          isLoading: false,
          error: null,
          user: user,
        );
        final schedulesResponse = await http.get(
          Uri.parse(AppApiConfig.getScheduleUrl('cm9n1ok5x00038ohc8boavle3')),
        );
        if (schedulesResponse.statusCode == 200) {
          final List<dynamic> schedulesData = json.decode(schedulesResponse.body);
          final List<Schedule> schedules = schedulesData
              .map((schedule) => Schedule.fromJson(schedule))
              .toList()
              .cast<Schedule>();
          state = state.copyWith(
            schedules: schedules,
          );
        }
        return "signedIn";
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch user data: ${response.statusCode}',
        );
        return "failedToSignIn";
      }
    } catch (e) {
      print('Auth - Error during sign in: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return "failedToSignIn";
    }
  }

  void signOut() {
    print('Auth - Signing out, resetting to initial state');
    state = AuthState.initial();
  }
}
