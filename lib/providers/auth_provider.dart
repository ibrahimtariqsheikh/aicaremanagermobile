import 'package:aicaremanagermob/models/schedule.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
//  import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aicaremanagermob/configs/app_api_config.dart';
import '../models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:aicaremanagermob/providers/schedule_provider.dart';
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

  const AuthState({
    required this.isLoading,
    required this.error,
    required this.user,
  });

  @override
  List<Object?> get props => [isLoading, error, user];

  @override
  bool get stringify => true;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  factory AuthState.initial() {
    return AuthState(
      isLoading: false,
      error: null,
      user: _defaultUser,
    );
  }
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      print('signIn with email: $email');
      state = state.copyWith(isLoading: true);

      final response = await http.get(
        Uri.parse(AppApiConfig.getUserUrl('cm9n1ok5x00038ohc8boavle3')),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final userData = responseData['data'];
        final user = User.fromJson(userData);

        state = state.copyWith(
          isLoading: false,
          error: null,
          user: user,
        );

        // Load schedules using the actual user ID
        ref.read(scheduleNotifierProvider.notifier).loadSchedules(user.id);
        return 'signedIn';
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch user data: ${response.statusCode}',
        );
        return 'failedToSignIn';
      }
    } catch (e) {
      print(e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return 'failedToSignIn';
    }
  }

  void signOut() {
    state = AuthState.initial();
  }
}
