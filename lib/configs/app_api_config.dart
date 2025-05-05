class AppApiConfig {
  static const String baseUrl = 'http://192.168.2.106:3001';
  static const String userEndpoint = '/users/id';
 
  static String getUserUrl(String userId) => '$baseUrl$userEndpoint/$userId';
static const String scheduleEndpoint = '/schedules/careworker';
 static String getScheduleUrl(String userId) => '$baseUrl$scheduleEndpoint/$userId';

} 

