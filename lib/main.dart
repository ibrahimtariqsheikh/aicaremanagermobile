import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:aicaremanagermob/pages/homepage.dart';
import 'package:aicaremanagermob/configs/build_routes.dart';
import 'package:aicaremanagermob/pages/sign_in_page.dart';
// import 'package:aicaremanagermob/configs/amplify_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await AmplifyConfig.configure();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AICare Manager',
      theme: AppTheme.light().copyWith(
        textTheme: AppTheme.light().textTheme.apply(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
      ),
      darkTheme: AppTheme.dark().copyWith(
        textTheme: AppTheme.dark().textTheme.apply(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
      ),
      themeMode: ThemeMode.system,
      onGenerateRoute: buildRoutes,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      builder: (context, child) {
        return DefaultTextStyle(
          style: const TextStyle(
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          ),
          child: child!,
        );
      },
      home: const SignInPage(),
    );
  }
}

