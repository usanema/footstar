import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_constants.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('FootStar Initialized')),
      ),
    );
  }
}
