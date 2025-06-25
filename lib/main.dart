import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
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
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginScreen(), // Halaman awal
    );
  }
}
