import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import 'screens/home_page.dart';
import 'services/api/api_client.dart';
import 'services/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.shouldUseSupabase) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    final isLoggedIn =
        Supabase.instance.client.auth.currentSession != null;
    runApp(TravelMateApp(isLoggedIn: isLoggedIn));
    return;
  }

  // Fallback: the original REST API backend remains fully available.
  final isLoggedIn = await ApiClient.instance.hasToken();
  runApp(TravelMateApp(isLoggedIn: isLoggedIn));
}

class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key, this.isLoggedIn = false});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TravelMate',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF7FAFC),
      ),
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
