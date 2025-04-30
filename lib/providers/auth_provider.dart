//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
//  import 'package:amplify_flutter/amplify_flutter.dart';
//  import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

part 'auth_provider.g.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final String? token;
  final bool isAuthenticated;
  // final AuthUser? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.token,
    this.isAuthenticated = false,
    // this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? token,
    bool? isAuthenticated,
    // AuthUser? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      // user: user ?? this.user,
    );
  }
}

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    // _checkCurrentSession();
    return const AuthState();
  }

  // Future<void> _checkCurrentSession() async {
  //   try {
  //     final session = await Amplify.Auth.fetchAuthSession();
  //     if (session.isSignedIn) {
  //       final user = await Amplify.Auth.getCurrentUser();
  //       state = state.copyWith(
  //         isAuthenticated: true,
  //         user: user,
  //       );
  //     }
  //   } catch (e) {
  //     safePrint('Error checking session: $e');
  //   }
  // }

  // Future<void> signIn(String email, String password) async {
  //   state = state.copyWith(isLoading: true, error: null);

  //   try {
  //     final result = await Amplify.Auth.signIn(
  //       username: email,
  //       password: password,
  //     );
      
  //     if (result.isSignedIn) {
  //       final user = await Amplify.Auth.getCurrentUser();
  //       state = state.copyWith(
  //         isLoading: false,
  //         isAuthenticated: true,
  //         user: user,
  //       );
  //     } else {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: 'Sign in failed. Please check your credentials.',
  //       );
  //     }
  //   } on AuthException catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: e.message,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: 'An unexpected error occurred. Please try again.',
  //     );
  //   }
  // }

  // Future<void> signOut() async {
  //   try {
  //     await Amplify.Auth.signOut();
  //     state = const AuthState();
  //   } catch (e) {
  //     state = state.copyWith(
  //       error: 'Failed to sign out. Please try again.',
  //     );
  //   }
  }
