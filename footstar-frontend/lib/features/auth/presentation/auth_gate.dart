import 'package:flutter/material.dart';
import '../../onboarding/data/profile_repository.dart';
import '../../onboarding/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../home/presentation/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return FutureBuilder<ProfileModel?>(
            future: ProfileRepository().getProfile(session.user.id),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (profileSnapshot.hasData && profileSnapshot.data != null) {
                // User has a profile, go to Home
                return const HomeScreen();
              } else {
                // User logged in but no profile, go to Onboarding
                return const OnboardingScreen();
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
