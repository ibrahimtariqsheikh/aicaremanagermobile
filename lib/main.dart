import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:aicaremanagermob/pages/homepage.dart';
import 'package:aicaremanagermob/configs/build_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AICare Manager',

    theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          onGenerateRoute: buildRoutes,
          debugShowCheckedModeBanner: false,
          debugShowMaterialGrid: false,
          showPerformanceOverlay: false,
          showSemanticsDebugger: false,
      home: const HomePage(),
    );
  }
}

