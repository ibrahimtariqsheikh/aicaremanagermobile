class AppApiConfig {
  static const String baseUrl = 'http://localhost:3001';
  static const String userEndpoint = '/users/id';

  static const currentTestingAgencyId = 'cm9n1czjs00018owbxcyue7ra';

  static String getUserUrl(String userId) => '$baseUrl$userEndpoint/$userId';
  static const String scheduleEndpoint = '/schedules/careworker';
  static String getScheduleUrl(String userId) =>
      '$baseUrl$scheduleEndpoint/$userId';

  static const String reportEndpoint = '/reports/user';

  static String getCareworkerReportUrl(String userId) =>
      '$baseUrl$reportEndpoint/$userId';

  static String getAgencyUsersUrl() =>
      '$baseUrl/users/agency/$currentTestingAgencyId';

  static const createReportEndpoint = '/reports/create';
  static String getCreateReportUrl(String userId, String scheduleId) =>
      '$baseUrl$createReportEndpoint/$userId/$currentTestingAgencyId/$scheduleId';
}
