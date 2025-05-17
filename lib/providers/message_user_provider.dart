import 'package:aicaremanagermob/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aicaremanagermob/configs/app_api_config.dart';
import 'package:equatable/equatable.dart';

part 'message_user_provider.g.dart';

enum UserRoleTab {
  clients,
  careWorkers,
  officeStaff,
  all,
}

// Agency Users State
class MessageUsersState extends Equatable {
  final List<User> clients;
  final List<User> careworkers;
  final List<User> officeStaff;
  final List<User> allUsers;
  final bool isLoading;
  final String? error;
  final UserRoleTab selectedTab;

  const MessageUsersState({
    this.clients = const [],
    this.careworkers = const [],
    this.officeStaff = const [],
    this.allUsers = const [],
    this.isLoading = false,
    this.error,
    this.selectedTab = UserRoleTab.clients,
  });

  @override
  List<Object?> get props =>
      [clients, careworkers, officeStaff, isLoading, error, selectedTab];

  MessageUsersState copyWith({
    List<User>? clients,
    List<User>? careworkers,
    List<User>? officeStaff,
    List<User>? allUsers,
    bool? isLoading,
    String? error,
    UserRoleTab? selectedTab,
  }) {
    return MessageUsersState(
      clients: clients ?? this.clients,
      careworkers: careworkers ?? this.careworkers,
      officeStaff: officeStaff ?? this.officeStaff,
      allUsers: allUsers ?? this.allUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  List<User> get filteredUsers {
    switch (selectedTab) {
      case UserRoleTab.all:
        return allUsers;
      case UserRoleTab.clients:
        return clients;
      case UserRoleTab.careWorkers:
        return careworkers;
      case UserRoleTab.officeStaff:
        return officeStaff;
    }
  }
}

@riverpod
class MessageUsersNotifier extends _$MessageUsersNotifier {
  @override
  MessageUsersState build() {
    return const MessageUsersState(
      selectedTab: UserRoleTab.clients,
      clients: [],
      careworkers: [],
      officeStaff: [],
      allUsers: [],
      isLoading: false,
    );
  }

  void setSelectedTab(UserRoleTab tab) {
    if (tab != state.selectedTab) {
      state = state.copyWith(selectedTab: tab);
    }
  }

  Future<void> loadMessageUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await http.get(
        Uri.parse(AppApiConfig.getAgencyUsersUrl()),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Extract data array from response
        final List<dynamic> usersData = responseData['data'] ?? [];

        // Get meta information if needed
        final int totalUsers = responseData['meta']?['total'] ?? 0;

        print('Loaded $totalUsers agency users');

        final List<User> users =
            usersData.map((userData) => User.fromJson(userData)).toList();

        final List<User> allUsers = users;

        final List<User> clients =
            users.where((user) => user.role == Role.CLIENT).toList();
        final List<User> careworkers =
            users.where((user) => user.role == Role.CARE_WORKER).toList();
        final List<User> officeStaff =
            users.where((user) => user.role == Role.OFFICE_STAFF).toList();

        print(clients);
        print(careworkers);
        print(officeStaff);

        state = state.copyWith(
          clients: clients,
          careworkers: careworkers,
          officeStaff: officeStaff,
          allUsers: allUsers,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load agency users: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error loading agency users: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
