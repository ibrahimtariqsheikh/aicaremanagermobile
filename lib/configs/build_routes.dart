import 'package:aicaremanagermob/pages/homepage.dart';
import 'package:flutter/cupertino.dart';

Route<dynamic> buildRoutes(RouteSettings settings) {
  WidgetBuilder builder;
  switch (settings.name) {
    case HomePage.routeName:
      builder = (BuildContext context) => const HomePage();
      break;
    default:
      throw Exception('Invalid route: ${settings.name}');
  }
  return CupertinoPageRoute(builder: builder, settings: settings);
}
