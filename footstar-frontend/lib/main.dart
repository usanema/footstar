import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_constants.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/registration_screen.dart';
import 'features/home/presentation/dashboard_screen.dart';

import 'package:footstars/core/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const FootStarApp());
}

class FootStarApp extends StatelessWidget {
  const FootStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FootStar',
      // Force Dark Mode as per "Pitch Black" aesthetic
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) =>
            const DashboardScreen(), // Add named route if needed, or just pushReplacement
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
