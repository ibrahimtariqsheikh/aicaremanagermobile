// ignore_for_file: avoid_print

import 'package:aicaremanagermob/configs/amplify_config.dart';
import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:aicaremanagermob/configs/build_routes.dart';
import 'package:aicaremanagermob/pages/oboarding/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aicaremanagermob/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Theme provider for managing theme state
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

Future<void> _configureAmplify() async {
  try {
    // Load environment variables
    await dotenv.load();

    // Add plugins
    await Amplify.addPlugins([AmplifyAuthCognito()]);

    // Configure Amplify
    await Amplify.configure(amplifyConfig);
  } catch (e) {
    rethrow; // Rethrow the error to see the full stack trace
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _configureAmplify();

    // Create a ProviderContainer to pre-initialize providers
    final container = ProviderContainer();
    // Pre-initialize auth provider
    container.read(authProvider);

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Failed to initialize app: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return MaterialApp(
      title: 'AICare Manager',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      onGenerateRoute: buildRoutes,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      builder: (context, child) {
        return DefaultTextStyle(
          style: GoogleFonts.inter(
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
          child: child!,
        );
      },
      home: const SplashPage(),
    );
  }
}
