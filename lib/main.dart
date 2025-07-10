import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inisialisasi Supabase tanpa authFlowType
  await Supabase.initialize(
    url: 'https://chmitzjtxvvokcwafqwi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNobWl0emp0eHZ2b2tjd2FmcXdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxNjUwODksImV4cCI6MjA2NTc0MTA4OX0.YcWduv2-ldx9qdy4GcdI3_GiKwvki56fcnWsL7jmINs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatatan Keuangan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AuthGate(), // Mengecek apakah sudah login
    );
  }
}

/// Mengecek apakah user sudah login
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // Jika belum login, arahkan ke LoginScreen
    if (session == null) {
      return const LoginScreen();
    } else {
      return const DashboardScreen(); // Jika sudah login, arahkan ke dashboard
    }
  }
}
